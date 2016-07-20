# ===--- SwiftFloatingPointTypes.py ----------------------------*- coding: utf-8 -*-===//
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See http://swift.org/LICENSE.txt for license information
# See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

# returns (lower, upper) exclusive bounds for the integer values
# that can be stored into a float
def getFtoIBounds(floatBits, intBits, signed):
  sigBits = floating_point_bits_to_type()[floatBits].explicit_significand_bits
  if not signed:
    return (-1, 1 << intBits)
  upper = 1 << (intBits - 1)
  if intBits <= sigBits:
    return (-upper - 1, upper)
  ulp = 1 << (intBits - sigBits)
  return (-upper - ulp, upper)

class SwiftFloatType(object):
    
    def __init__(self, name, cFuncSuffix, significandBits, exponentBits, significandSize, totalBits):
        self.stdlib_name = name
        self.cFuncSuffix = cFuncSuffix
        self.significand_bits = significandBits
        self.significand_size = significandSize
        self.exponent_bits = exponentBits
        self.explicit_significand_bits = significandBits + 1
        self.bits = totalBits
        
def floating_point_bits_to_type():
    return {
        32: SwiftFloatType(name="Float",   cFuncSuffix="f", significandBits=23, exponentBits=8,  significandSize=32, totalBits=32),
        64: SwiftFloatType(name="Double",  cFuncSuffix="",  significandBits=52, exponentBits=11, significandSize=64, totalBits=64),
        80: SwiftFloatType(name="Float80", cFuncSuffix="l", significandBits=63, exponentBits=15, significandSize=64, totalBits=80),
    }

def all_floating_point_types():
    return floating_point_bits_to_type().values()

# // Bit counts for all floating point types. 
# // 80-bit floating point types are only permitted on x86 architectures. This
# // restriction is handled via #if's in the generated code.
def all_floating_point_bits():
    return floating_point_bits_to_type().keys()
