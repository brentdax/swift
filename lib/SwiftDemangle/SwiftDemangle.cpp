//===--- SwiftDemangle.cpp - Public demangling interface ------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// Functions in the libswiftDemangle library, which provides external
// access to Swift's demangler.
//
//===----------------------------------------------------------------------===//

#include "swift/Demangling/Demangle.h"
#include "swift/Demangling/Demangler.h"
#include "swift-c/SwiftDemangle/SwiftDemangle.h"

static size_t swift_demangle_getDemangledName_Options(const char *MangledName,
    char *OutputBuffer, size_t Length,
    swift::Demangle::DemangleOptions DemangleOptions) {
  assert(MangledName != nullptr && "null input");
  assert(OutputBuffer != nullptr || Length == 0);

  if (!swift::Demangle::isSwiftSymbol(MangledName))
    return 0; // Not a mangled name

  std::string Result = swift::Demangle::demangleSymbolAsString(
      llvm::StringRef(MangledName), DemangleOptions);

  if (Result == MangledName)
    return 0; // Not a mangled name

  // Copy the result to an output buffer and ensure '\0' termination.
  if (OutputBuffer && Length > 0) {
    auto Dest = strncpy(OutputBuffer, Result.c_str(), Length);
    Dest[Length - 1] = '\0';
  }
  return Result.length();
}

size_t swift_demangle_getDemangledName(const char *MangledName,
                                       char *OutputBuffer,
                                       size_t Length) {
  swift::Demangle::DemangleOptions DemangleOptions;
  DemangleOptions.SynthesizeSugarOnTypes = true;
  return swift_demangle_getDemangledName_Options(MangledName, OutputBuffer,
                                                 Length, DemangleOptions);
}

size_t swift_demangle_getSimplifiedDemangledName(const char *MangledName,
                                                 char *OutputBuffer,
                                                 size_t Length) {
  auto Opts = swift::Demangle::DemangleOptions::SimplifiedUIDemangleOptions();
  return swift_demangle_getDemangledName_Options(MangledName, OutputBuffer,
                                                 Length, Opts);
}

size_t swift_demangle_getModuleName(const char *MangledName,
                                    char *OutputBuffer,
                                    size_t Length) {

  swift::Demangle::Context DCtx;
  std::string Result = DCtx.getModuleName(llvm::StringRef(MangledName));

  // Copy the result to an output buffer and ensure '\0' termination.
  if (OutputBuffer && Length > 0) {
    auto Dest = strncpy(OutputBuffer, Result.c_str(), Length);
    Dest[Length - 1] = '\0';
  }
  return Result.length();
}


int swift_demangle_hasSwiftCallingConvention(const char *MangledName) {
  swift::Demangle::Context DCtx;
  if (DCtx.hasSwiftCallingConvention(llvm::StringRef(MangledName)))
    return 1;
  return 0;
}

size_t fnd_get_demangled_name(const char *MangledName, char *OutputBuffer,
                              size_t Length) {
  return swift_demangle_getDemangledName(MangledName, OutputBuffer, Length);
}

struct swift_demangler {
  swift::Demangle::Demangler D;

  const char * dup(StringRef str) {
    auto buffer = D.Allocate<char>(str.size() + 1);
    memcpy(buffer, str.data(), str.size());
    buffer[str.size()] = '\0';
    return buffer;
  }
};

swift_demangler_t swift_demangler_alloc(void) {
  return new swift_demangler();
}

void swift_demangler_dealloc(swift_demangler_t demangler) {
  delete demangler;
}

swift_demangler_node_t
swift_demangler_demangleSymbolToNode(swift_demangler_t demangler,
                                     const char * symbol) {
  if (isMangledName(symbol)) {
    return demangler->D.demangleSymbol(symbol);
  }
  return demangleOldSymbolAsNode(symbol, demangler->D);
}

swift_demangler_node_t
swift_demangler_demangleTypeToNode(swift_demangler_t demangler,
                                   const char * type) {
  return demangler->D.demangleType(type);
}

void swift_demangler_dumpNode(swift_demangler_node_t node) {
  static_cast<swift::Demangle::NodePointer>(node)->dump();
}

swift_demangler_node_kind_t
swift_demangler_getNodeKind(swift_demangler_node_t node) {
  return swift_demangler_node_kind_t(
      static_cast<swift::Demangle::NodePointer>(node)->getKind());
}

const char * _Nonnull
swift_demangler_getNodeKindName(swift_demangler_node_kind_t kind) {
  return swift::Demangle::getNodeKindString(swift::Demangle::Node::Kind(kind));
}

swift_demangler_node_payload_kind_t
swift_demangler_getNodePayloadKind(swift_demangler_node_t node) {
  if (static_cast<swift::Demangle::NodePointer>(node)->hasText())
    return swift_demangler_node_payload_kind_Text;
  else if (static_cast<swift::Demangle::NodePointer>(node)->hasIndex())
    return swift_demangler_node_payload_kind_Index;
  else
    return swift_demangler_node_payload_kind_Children;
}

size_t
swift_demangler_getNumNodeChildren(swift_demangler_node_t node) {
  return static_cast<swift::Demangle::NodePointer>(node)->getNumChildren();
}

swift_demangler_node_t
swift_demangler_getNodeChild(swift_demangler_node_t node, size_t index) {
  return static_cast<swift::Demangle::NodePointer>(node)->getChild(index);
}

uint64_t
swift_demangler_getNodeIndex(swift_demangler_node_t node) {
  return static_cast<swift::Demangle::NodePointer>(node)->getIndex();
}

const char *
swift_demangler_getNodeText(swift_demangler_t demangler,
                            swift_demangler_node_t node) {
  return demangler->dup(
      static_cast<swift::Demangle::NodePointer>(node)->getText());
}

const char *
swift_demangler_getRemangledNode(swift_demangler_t demangler,
                                 swift_demangler_node_t node) {
  return demangler->dup(
      swift::Demangle::mangleNode(
        static_cast<swift::Demangle::NodePointer>(node),
        [&](SymbolicReferenceKind, const void *) { return nullptr; },
        demangler->D));
}

