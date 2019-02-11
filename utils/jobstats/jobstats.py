#!/usr/bin/python
#
# ==-- jobstats - support for reading the contents of stats dirs --==#
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014-2017 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information
# See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
#
# ==------------------------------------------------------------------------==#
#
# This file contains subroutines for loading object-representations of one or
# more directories generated by `swiftc -stats-output-dir`.

import datetime
import itertools
import json
import os
import platform
import random
import re


class JobData(object):

    def __init__(self, jobkind, jobid, module, jobargs):
        self.jobkind = jobkind
        self.jobid = jobid
        self.module = module
        self.jobargs = jobargs
        (self.input, self.triple, self.out, self.opt) = jobargs[0:4]

    def is_driver_job(self):
        """Return true iff self measures a driver job"""
        return self.jobkind == 'driver'

    def is_frontend_job(self):
        """Return true iff self measures a frontend job"""
        return self.jobkind == 'frontend'


class JobProfs(JobData):
    """Object denoting the profile of a single job run during a compilation,
    corresponding to a single directory of profiles produced by a single
    job process passed -stats-output-dir."""

    def __init__(self, jobkind, jobid, module, jobargs, profiles):
        self.profiles = profiles
        super(JobProfs, self).__init__(jobkind, jobid, module, jobargs)


class JobStats(JobData):
    """Object holding the stats of a single job run during a compilation,
    corresponding to a single JSON file produced by a single job process
    passed -stats-output-dir."""

    def __init__(self, jobkind, jobid, module, start_usec, dur_usec,
                 jobargs, stats):
        self.start_usec = start_usec
        self.dur_usec = dur_usec
        self.stats = stats
        super(JobStats, self).__init__(jobkind, jobid, module, jobargs)

    def driver_jobs_ran(self):
        """Return the count of a driver job's ran sub-jobs"""
        assert(self.is_driver_job())
        return self.stats.get("Driver.NumDriverJobsRun", 0)

    def driver_jobs_skipped(self):
        """Return the count of a driver job's skipped sub-jobs"""
        assert(self.is_driver_job())
        return self.stats.get("Driver.NumDriverJobsSkipped", 0)

    def driver_jobs_total(self):
        """Return the total count of a driver job's ran + skipped sub-jobs"""
        assert(self.is_driver_job())
        return self.driver_jobs_ran() + self.driver_jobs_skipped()

    def merged_with(self, other, merge_by="sum"):
        """Return a new JobStats, holding the merger of self and other"""
        merged_stats = {}
        ops = {"sum": lambda a, b: a + b,
               # Because 0 is also a sentinel on counters we do a modified
               # "nonzero-min" here. Not ideal but best we can do.
               "min": lambda a, b: (min(a, b)
                                    if a != 0 and b != 0
                                    else max(a, b)),
               "max": lambda a, b: max(a, b)}
        op = ops[merge_by]
        for k, v in self.stats.items() + other.stats.items():
            if k in merged_stats:
                merged_stats[k] = op(v, merged_stats[k])
            else:
                merged_stats[k] = v
        merged_kind = self.jobkind
        if other.jobkind != merged_kind:
            merged_kind = "<merged>"
        merged_module = self.module
        if other.module != merged_module:
            merged_module = "<merged>"
        merged_start = min(self.start_usec, other.start_usec)
        merged_end = max(self.start_usec + self.dur_usec,
                         other.start_usec + other.dur_usec)
        merged_dur = merged_end - merged_start
        return JobStats(merged_kind, random.randint(0, 1000000000),
                        merged_module, merged_start, merged_dur,
                        self.jobargs + other.jobargs, merged_stats)

    def prefixed_by(self, prefix):
        prefixed_stats = dict([((prefix + "." + k), v)
                               for (k, v) in self.stats.items()])
        return JobStats(self.jobkind, random.randint(0, 1000000000),
                        self.module, self.start_usec, self.dur_usec,
                        self.jobargs, prefixed_stats)

    def divided_by(self, n):
        divided_stats = dict([(k, v / n)
                              for (k, v) in self.stats.items()])
        return JobStats(self.jobkind, random.randint(0, 1000000000),
                        self.module, self.start_usec, self.dur_usec,
                        self.jobargs, divided_stats)

    def incrementality_percentage(self):
        """Assuming the job is a driver job, return the amount of
        jobs that actually ran, as a percentage of the total number."""
        assert(self.is_driver_job())
        ran = self.driver_jobs_ran()
        total = self.driver_jobs_total()
        return round((float(ran) / float(total)) * 100.0, 2)

    def to_catapult_trace_obj(self):
        """Return a JSON-formattable object fitting chrome's
        'catapult' trace format"""
        return {"name": self.module,
                "cat": self.jobkind,
                "ph": "X",              # "X" == "complete event"
                "pid": self.jobid,
                "tid": 1,
                "ts": self.start_usec,
                "dur": self.dur_usec,
                "args": self.jobargs}

    def start_timestr(self):
        """Return a formatted timestamp of the job's start-time"""
        t = datetime.datetime.fromtimestamp(self.start_usec / 1000000.0)
        return t.strftime("%Y-%m-%d %H:%M:%S")

    def end_timestr(self):
        """Return a formatted timestamp of the job's end-time"""
        t = datetime.datetime.fromtimestamp((self.start_usec +
                                             self.dur_usec) / 1000000.0)
        return t.strftime("%Y-%m-%d %H:%M:%S")

    def pick_lnt_metric_suffix(self, metric_name):
        """Guess an appropriate LNT metric type for a given metric name"""
        if "BytesOutput" in metric_name:
            return "code_size"
        if "RSS" in metric_name or "BytesAllocated" in metric_name:
            return "mem"
        return "compile"

    def to_lnt_test_obj(self, args):
        """Return a JSON-formattable object fitting LNT's 'submit' format"""
        run_info = {
            "run_order": str(args.lnt_order),
            "tag": str(args.lnt_tag),
        }
        run_info.update(dict(args.lnt_run_info))
        stats = self.stats
        return {
            "Machine":
            {
                "Name": args.lnt_machine,
                "Info": dict(args.lnt_machine_info)
            },
            "Run":
            {
                "Start Time": self.start_timestr(),
                "End Time": self.end_timestr(),
                "Info": run_info
            },
            "Tests":
            [
                {
                    "Data": [v],
                    "Info": {},
                    "Name": "%s.%s.%s.%s" % (args.lnt_tag, self.module,
                                             k, self.pick_lnt_metric_suffix(k))
                }
                for (k, v) in stats.items()
            ]
        }


AUXPATSTR = (r"(?P<module>[^-]+)-(?P<input>[^-]+)-(?P<triple>[^-]+)" +
             r"-(?P<out>[^-]*)-(?P<opt>[^-]+)")
AUXPAT = re.compile(AUXPATSTR)

TIMERPATSTR = (r"time\.swift-(?P<jobkind>\w+)\." + AUXPATSTR +
               r"\.(?P<timerkind>\w+)$")
TIMERPAT = re.compile(TIMERPATSTR)

FILEPATSTR = (r"^stats-(?P<start>\d+)-swift-(?P<kind>\w+)-" +
              AUXPATSTR +
              r"-(?P<pid>\d+)(-.*)?.json$")
FILEPAT = re.compile(FILEPATSTR)

PROFILEPATSTR = (r"^profile-(?P<start>\d+)-swift-(?P<kind>\w+)-" +
                 AUXPATSTR +
                 r"-(?P<pid>\d+)(-.*)?.dir$")
PROFILEPAT = re.compile(PROFILEPATSTR)


def match_auxpat(s):
    m = AUXPAT.match(s)
    if m is not None:
        return m.groupdict()
    else:
        return None


def match_timerpat(s):
    m = TIMERPAT.match(s)
    if m is not None:
        return m.groupdict()
    else:
        return None


def match_filepat(s):
    m = FILEPAT.match(s)
    if m is not None:
        return m.groupdict()
    else:
        return None


def match_profilepat(s):
    m = PROFILEPAT.match(s)
    if m is not None:
        return m.groupdict()
    else:
        return None


def find_profiles_in(profiledir, select_stat=[]):
    sre = re.compile('.*' if len(select_stat) == 0 else
                     '|'.join(select_stat))
    profiles = None
    for profile in os.listdir(profiledir):
        if profile.endswith(".svg"):
            continue
        if sre.search(profile) is None:
            continue
        fullpath = os.path.join(profiledir, profile)
        s = os.stat(fullpath)
        if s.st_size != 0:
            if profiles is None:
                profiles = dict()
            try:
                (counter, profiletype) = os.path.splitext(profile)
                # drop leading period from extension
                profiletype = profiletype[1:]
                if profiletype not in profiles:
                    profiles[profiletype] = dict()
                profiles[profiletype][counter] = fullpath
            except Exception:
                pass
    return profiles


def list_stats_dir_profiles(path, select_module=[], select_stat=[], **kwargs):
    """Finds all stats-profiles in path, returning list of JobProfs objects"""
    jobprofs = []
    for root, dirs, files in os.walk(path):
        for d in dirs:
            mg = match_profilepat(d)
            if not mg:
                continue
            # NB: "pid" in fpat is a random number, not unix pid.
            jobkind = mg['kind']
            jobid = int(mg['pid'])
            module = mg["module"]
            if len(select_module) != 0 and module not in select_module:
                continue
            jobargs = [mg["input"], mg["triple"], mg["out"], mg["opt"]]

            e = JobProfs(jobkind=jobkind, jobid=jobid,
                         module=module, jobargs=jobargs,
                         profiles=find_profiles_in(os.path.join(root, d),
                                                   select_stat))
            jobprofs.append(e)
    return jobprofs


def load_stats_dir(path, select_module=[], select_stat=[],
                   exclude_timers=False, merge_timers=False, **kwargs):
    """Loads all stats-files found in path into a list of JobStats objects"""
    jobstats = []
    sre = re.compile('.*' if len(select_stat) == 0 else
                     '|'.join(select_stat))
    for root, dirs, files in os.walk(path):
        for f in files:
            mg = match_filepat(f)
            if not mg:
                continue
            # NB: "pid" in fpat is a random number, not unix pid.
            jobkind = mg['kind']
            jobid = int(mg['pid'])
            start_usec = int(mg['start'])
            module = mg["module"]
            if len(select_module) != 0 and module not in select_module:
                continue
            jobargs = [mg["input"], mg["triple"], mg["out"], mg["opt"]]

            if platform.system() == 'Windows':
                p = unicode(u"\\\\?\\%s" % os.path.abspath(os.path.join(root,
                                                                        f)))
            else:
                p = os.path.join(root, f)

            with open(p) as fp:
                j = json.load(fp)
            dur_usec = 1
            stats = dict()
            for (k, v) in j.items():
                if sre.search(k) is None:
                    continue
                if k.startswith('time.') and exclude_timers:
                    continue
                tm = match_timerpat(k)
                if tm:
                    v = int(1000000.0 * float(v))
                    if tm['jobkind'] == jobkind and \
                       tm['timerkind'] == 'wall':
                        dur_usec = v
                    if merge_timers:
                        k = "time.swift-%s.%s" % (tm['jobkind'],
                                                  tm['timerkind'])
                stats[k] = v

            e = JobStats(jobkind=jobkind, jobid=jobid,
                         module=module, start_usec=start_usec,
                         dur_usec=dur_usec, jobargs=jobargs,
                         stats=stats)
            jobstats.append(e)
    return jobstats


def merge_all_jobstats(jobstats, select_module=[], group_by_module=False,
                       merge_by="sum", divide_by=1, **kwargs):
    """Does a pairwise merge of the elements of list of jobs"""
    m = None
    if len(select_module) > 0:
        jobstats = filter(lambda j: j.module in select_module, jobstats)
    if group_by_module:
        def keyfunc(j):
            return j.module
        jobstats = list(jobstats)
        jobstats.sort(key=keyfunc)
        prefixed = []
        for mod, group in itertools.groupby(jobstats, keyfunc):
            groupmerge = merge_all_jobstats(group, merge_by=merge_by,
                                            divide_by=divide_by)
            prefixed.append(groupmerge.prefixed_by(mod))
        jobstats = prefixed
    for j in jobstats:
        if m is None:
            m = j
        else:
            m = m.merged_with(j, merge_by=merge_by)
    if m is None:
        return m
    return m.divided_by(divide_by)
