//===--- SwiftDemangle.h - Public demangling interface ----------*- C++ -*-===//
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
///
/// \file
/// This header declares functions in the libswiftDemangle library,
/// which provides external access to Swift's demangler.
///
//===----------------------------------------------------------------------===//

#ifndef SWIFT_DEMANGLE_SWIFT_DEMANGLE_H
#define SWIFT_DEMANGLE_SWIFT_DEMANGLE_H

#include <stddef.h>
#include "Platform.h"

/// @{
/// Version constants for libswiftDemangle library.

/// Major version changes when there are ABI or source incompatible changes.
#define SWIFT_DEMANGLE_VERSION_MAJOR 1

/// Minor version changes when new APIs are added in ABI- and source-compatible
/// way.
#define SWIFT_DEMANGLE_VERSION_MINOR 2

/// @}

#ifdef __cplusplus
extern "C" {
#endif

/// Demangle Swift function names.
///
/// \returns the length of the demangled function name (even if greater than the
/// size of the output buffer) or 0 if the input is not a Swift-mangled function
/// name (in which cases \p OutputBuffer is left untouched).
SWIFT_DEMANGLE_LINKAGE
size_t swift_demangle_getDemangledName(const char *MangledName,
                                       char *OutputBuffer, size_t Length);

/// Demangle Swift function names with module names and implicit self
/// and metatype type names in function signatures stripped.
///
/// \returns the length of the demangled function name (even if greater than the
/// size of the output buffer) or 0 if the input is not a Swift-mangled function
/// name (in which cases \p OutputBuffer is left untouched).
SWIFT_DEMANGLE_LINKAGE
size_t swift_demangle_getSimplifiedDemangledName(const char *MangledName,
                                                 char *OutputBuffer,
                                                 size_t Length);

/// Demangle a Swift symbol and return the module name of the mangled entity.
///
/// \returns the length of the demangled module name (even if greater than the
/// size of the output buffer) or 0 if the input is not a Swift-mangled name
/// (in which cases \p OutputBuffer is left untouched).
SWIFT_DEMANGLE_LINKAGE
size_t swift_demangle_getModuleName(const char *MangledName,
                                    char *OutputBuffer,
                                    size_t Length);

/// Demangles a Swift function name and returns true if the function
/// conforms to the Swift calling convention.
///
/// \returns true if the function conforms to the Swift calling convention.
/// The return value is unspecified if the \p MangledName does not refer to a
/// function symbol.
SWIFT_DEMANGLE_LINKAGE
int swift_demangle_hasSwiftCallingConvention(const char *MangledName);

/// An instance which manages the lifetime of information about mangled names.
/// The memory returned by calls to the \c swift_demangler_context_*() and
/// \c swift_demangler_node_* will remain valid until the context is
/// deallocated.
typedef struct swift_demangler * swift_demangler_t
__attribute__((swift_wrapper(struct)))
__attribute__((swift_name("UnsafeSwiftDemangler")));

/// A node in a mangled name. Each node belongs to the
/// \c swift_demangler_context_t used to create it and
typedef void * swift_demangler_node_t
__attribute__((swift_wrapper(struct)))
__attribute__((swift_name("UnsafeSwiftDemanglerNode")));

/// Creates a new Swift demangler.
SWIFT_DEMANGLE_LINKAGE
swift_demangler_t _Nonnull
swift_demangler_alloc(void)
__attribute__((swift_name("UnsafeSwiftDemangler.init()")));

/// Destroys a Swift demangler and all of the nodes, strings, and other memory
/// associated with it.
///
/// \param demangler The demangler to destroy.
SWIFT_DEMANGLE_LINKAGE
void swift_demangler_dealloc(swift_demangler_t _Nonnull demangler)
__attribute__((swift_name("UnsafeSwiftDemangler.deallocate(self:)")));

/// Demangles an arbitrary Swift name and returns the parse tree.
///
/// \param demangler The demangler to use when demangling this symbol. The
/// returned node and all subobjects of it will remain valid until this
/// demangler is deallocated.
/// \param symbol A string containing the symbol name to demangle.
///
/// \return The root node of the parsed symbol, or null if it could not be
/// demangled.
SWIFT_DEMANGLE_LINKAGE
swift_demangler_node_t _Nullable
swift_demangler_demangleSymbolToNode(swift_demangler_t _Nonnull demangler,
                                     const char * _Nonnull symbol)
__attribute__((swift_name("UnsafeSwiftDemangler.node(self:fromSymbol:)")));

/// Demangles a Swift type name and returns the parse tree.
///
/// \param demangler The demangler to use when demangling this type. The
/// returned node and all subobjects of it will remain valid until this
/// demangler is deallocated.
/// \param type A string containing the type name to demangle.
///
/// \return The root node of the parsed type, or null if it could not be
/// demangled.
SWIFT_DEMANGLE_LINKAGE
swift_demangler_node_t _Nullable
swift_demangler_demangleTypeToNode(swift_demangler_t _Nonnull demangler,
                                   const char * _Nonnull type)
__attribute__((swift_name("UnsafeSwiftDemangler.node(self:fromType:)")));

/// Dumps the provided node to stderr; useful for debugging.
SWIFT_DEMANGLE_LINKAGE
void swift_demangler_dumpNode(swift_demangler_node_t _Nonnull node)
__attribute__((swift_name("UnsafeSwiftDemanglerNode.dump(self:)")));

#ifdef __cplusplus
} // extern "C"
#endif

// Old API.  To be removed when we remove the compatibility symlink.

/// @{
/// Version constants for libfunctionNameDemangle library.

/// Major version changes when there are ABI or source incompatible changes.
#define FUNCTION_NAME_DEMANGLE_VERSION_MAJOR 0

/// Minor version changes when new APIs are added in ABI- and source-compatible
/// way.
#define FUNCTION_NAME_DEMANGLE_VERSION_MINOR 2

/// @}

#ifdef __cplusplus
extern "C" {
#endif

/// Demangle Swift function names.
///
/// Note that this function has a generic name because it is called from
/// contexts where it is not appropriate to use code names.
///
/// \returns the length of the demangled function name (even if greater than the
/// size of the output buffer) or 0 if the input is not a Swift-mangled function
/// name (in which cases \p OutputBuffer is left untouched).
SWIFT_DEMANGLE_LINKAGE
size_t fnd_get_demangled_name(const char *MangledName, char *OutputBuffer,
                              size_t Length);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // SWIFT_DEMANGLE_SWIFT_DEMANGLE_H

