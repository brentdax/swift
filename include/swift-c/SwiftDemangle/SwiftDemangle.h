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
#include <stdint.h>
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

typedef enum __attribute__((enum_extensibility(open)))
swift_demangler_node_kind_t : uint16_t {
  swift_demangler_node_kind_Allocator,
  swift_demangler_node_kind_AnonymousContext,
  swift_demangler_node_kind_AnyProtocolConformanceList,
  swift_demangler_node_kind_ArgumentTuple,
  swift_demangler_node_kind_AssociatedType,
  swift_demangler_node_kind_AssociatedTypeRef,
  swift_demangler_node_kind_AssociatedTypeMetadataAccessor,
  swift_demangler_node_kind_DefaultAssociatedTypeMetadataAccessor,
  swift_demangler_node_kind_AssociatedTypeWitnessTableAccessor,
  swift_demangler_node_kind_BaseWitnessTableAccessor,
  swift_demangler_node_kind_AutoClosureType,
  swift_demangler_node_kind_BoundGenericClass,
  swift_demangler_node_kind_BoundGenericEnum,
  swift_demangler_node_kind_BoundGenericStructure,
  swift_demangler_node_kind_BoundGenericProtocol,
  swift_demangler_node_kind_BoundGenericOtherNominalType,
  swift_demangler_node_kind_BoundGenericTypeAlias,
  swift_demangler_node_kind_BoundGenericFunction,
  swift_demangler_node_kind_BuiltinTypeName,
  swift_demangler_node_kind_CFunctionPointer,
  swift_demangler_node_kind_Class,
  swift_demangler_node_kind_ClassMetadataBaseOffset,
  swift_demangler_node_kind_ConcreteProtocolConformance,
  swift_demangler_node_kind_Constructor,
  swift_demangler_node_kind_CoroutineContinuationPrototype,
  swift_demangler_node_kind_Deallocator,
  swift_demangler_node_kind_DeclContext,
  swift_demangler_node_kind_DefaultArgumentInitializer,
  swift_demangler_node_kind_DependentAssociatedConformance,
  swift_demangler_node_kind_DependentAssociatedTypeRef,
  swift_demangler_node_kind_DependentGenericConformanceRequirement,
  swift_demangler_node_kind_DependentGenericParamCount,
  swift_demangler_node_kind_DependentGenericParamType,
  swift_demangler_node_kind_DependentGenericSameTypeRequirement,
  swift_demangler_node_kind_DependentGenericLayoutRequirement,
  swift_demangler_node_kind_DependentGenericSignature,
  swift_demangler_node_kind_DependentGenericType,
  swift_demangler_node_kind_DependentMemberType,
  swift_demangler_node_kind_DependentPseudogenericSignature,
  swift_demangler_node_kind_DependentProtocolConformanceRoot,
  swift_demangler_node_kind_DependentProtocolConformanceInherited,
  swift_demangler_node_kind_DependentProtocolConformanceAssociated,
  swift_demangler_node_kind_Destructor,
  swift_demangler_node_kind_DidSet,
  swift_demangler_node_kind_Directness,
  swift_demangler_node_kind_DynamicAttribute,
  swift_demangler_node_kind_DirectMethodReferenceAttribute,
  swift_demangler_node_kind_DynamicSelf,
  swift_demangler_node_kind_DynamicallyReplaceableFunctionImpl,
  swift_demangler_node_kind_DynamicallyReplaceableFunctionKey,
  swift_demangler_node_kind_DynamicallyReplaceableFunctionVar,
  swift_demangler_node_kind_Enum,
  swift_demangler_node_kind_EnumCase,
  swift_demangler_node_kind_ErrorType,
  swift_demangler_node_kind_EscapingAutoClosureType,
  swift_demangler_node_kind_NoEscapeFunctionType,
  swift_demangler_node_kind_ExistentialMetatype,
  swift_demangler_node_kind_ExplicitClosure,
  swift_demangler_node_kind_Extension,
  swift_demangler_node_kind_FieldOffset,
  swift_demangler_node_kind_FullTypeMetadata,
  swift_demangler_node_kind_Function,
  swift_demangler_node_kind_FunctionSignatureSpecialization,
  swift_demangler_node_kind_FunctionSignatureSpecializationParam,
  swift_demangler_node_kind_FunctionSignatureSpecializationReturn,
  swift_demangler_node_kind_FunctionSignatureSpecializationParamKind,
  swift_demangler_node_kind_FunctionSignatureSpecializationParamPayload,
  swift_demangler_node_kind_FunctionType,
  swift_demangler_node_kind_GenericPartialSpecialization,
  swift_demangler_node_kind_GenericPartialSpecializationNotReAbstracted,
  swift_demangler_node_kind_GenericProtocolWitnessTable,
  swift_demangler_node_kind_GenericProtocolWitnessTableInstantiationFunction,
  swift_demangler_node_kind_ResilientProtocolWitnessTable,
  swift_demangler_node_kind_GenericSpecialization,
  swift_demangler_node_kind_GenericSpecializationNotReAbstracted,
  swift_demangler_node_kind_GenericSpecializationParam,
  swift_demangler_node_kind_InlinedGenericFunction,
  swift_demangler_node_kind_GenericTypeMetadataPattern,
  swift_demangler_node_kind_Getter,
  swift_demangler_node_kind_Global,
  swift_demangler_node_kind_GlobalGetter,
  swift_demangler_node_kind_Identifier,
  swift_demangler_node_kind_Index,
  swift_demangler_node_kind_IVarInitializer,
  swift_demangler_node_kind_IVarDestroyer,
  swift_demangler_node_kind_ImplEscaping,
  swift_demangler_node_kind_ImplConvention,
  swift_demangler_node_kind_ImplFunctionAttribute,
  swift_demangler_node_kind_ImplFunctionType,
  swift_demangler_node_kind_ImplicitClosure,
  swift_demangler_node_kind_ImplParameter,
  swift_demangler_node_kind_ImplResult,
  swift_demangler_node_kind_ImplErrorResult,
  swift_demangler_node_kind_InOut,
  swift_demangler_node_kind_InfixOperator,
  swift_demangler_node_kind_Initializer,
  swift_demangler_node_kind_KeyPathGetterThunkHelper,
  swift_demangler_node_kind_KeyPathSetterThunkHelper,
  swift_demangler_node_kind_KeyPathEqualsThunkHelper,
  swift_demangler_node_kind_KeyPathHashThunkHelper,
  swift_demangler_node_kind_LazyProtocolWitnessTableAccessor,
  swift_demangler_node_kind_LazyProtocolWitnessTableCacheVariable,
  swift_demangler_node_kind_LocalDeclName,
  swift_demangler_node_kind_MaterializeForSet,
  swift_demangler_node_kind_MergedFunction,
  swift_demangler_node_kind_Metatype,
  swift_demangler_node_kind_MetatypeRepresentation,
  swift_demangler_node_kind_Metaclass,
  swift_demangler_node_kind_MethodLookupFunction,
  swift_demangler_node_kind_ObjCMetadataUpdateFunction,
  swift_demangler_node_kind_ObjCResilientClassStub,
  swift_demangler_node_kind_FullObjCResilientClassStub,
  swift_demangler_node_kind_ModifyAccessor,
  swift_demangler_node_kind_Module,
  swift_demangler_node_kind_NativeOwningAddressor,
  swift_demangler_node_kind_NativeOwningMutableAddressor,
  swift_demangler_node_kind_NativePinningAddressor,
  swift_demangler_node_kind_NativePinningMutableAddressor,
  swift_demangler_node_kind_NominalTypeDescriptor,
  swift_demangler_node_kind_NonObjCAttribute,
  swift_demangler_node_kind_Number,
  swift_demangler_node_kind_ObjCAttribute,
  swift_demangler_node_kind_ObjCBlock,
  swift_demangler_node_kind_EscapingObjCBlock,
  swift_demangler_node_kind_OtherNominalType,
  swift_demangler_node_kind_OwningAddressor,
  swift_demangler_node_kind_OwningMutableAddressor,
  swift_demangler_node_kind_PartialApplyForwarder,
  swift_demangler_node_kind_PartialApplyObjCForwarder,
  swift_demangler_node_kind_PostfixOperator,
  swift_demangler_node_kind_PrefixOperator,
  swift_demangler_node_kind_PrivateDeclName,
  swift_demangler_node_kind_PropertyDescriptor,
  swift_demangler_node_kind_PropertyWrapperBackingInitializer,
  swift_demangler_node_kind_Protocol,
  swift_demangler_node_kind_ProtocolSymbolicReference,
  swift_demangler_node_kind_ProtocolConformance,
  swift_demangler_node_kind_ProtocolConformanceRefInTypeModule,
  swift_demangler_node_kind_ProtocolConformanceRefInProtocolModule,
  swift_demangler_node_kind_ProtocolConformanceRefInOtherModule,
  swift_demangler_node_kind_ProtocolDescriptor,
  swift_demangler_node_kind_ProtocolConformanceDescriptor,
  swift_demangler_node_kind_ProtocolList,
  swift_demangler_node_kind_ProtocolListWithClass,
  swift_demangler_node_kind_ProtocolListWithAnyObject,
  swift_demangler_node_kind_ProtocolSelfConformanceDescriptor,
  swift_demangler_node_kind_ProtocolSelfConformanceWitness,
  swift_demangler_node_kind_ProtocolSelfConformanceWitnessTable,
  swift_demangler_node_kind_ProtocolWitness,
  swift_demangler_node_kind_ProtocolWitnessTable,
  swift_demangler_node_kind_ProtocolWitnessTableAccessor,
  swift_demangler_node_kind_ProtocolWitnessTablePattern,
  swift_demangler_node_kind_ReabstractionThunk,
  swift_demangler_node_kind_ReabstractionThunkHelper,
  swift_demangler_node_kind_ReabstractionThunkHelperWithSelf,
  swift_demangler_node_kind_ReadAccessor,
  swift_demangler_node_kind_RelatedEntityDeclName,
  swift_demangler_node_kind_RetroactiveConformance,
  swift_demangler_node_kind_ReturnType,
  swift_demangler_node_kind_Shared,
  swift_demangler_node_kind_Owned,
  swift_demangler_node_kind_SILBoxType,
  swift_demangler_node_kind_SILBoxTypeWithLayout,
  swift_demangler_node_kind_SILBoxLayout,
  swift_demangler_node_kind_SILBoxMutableField,
  swift_demangler_node_kind_SILBoxImmutableField,
  swift_demangler_node_kind_Setter,
  swift_demangler_node_kind_SpecializationPassID,
  swift_demangler_node_kind_IsSerialized,
  swift_demangler_node_kind_Static,
  swift_demangler_node_kind_Structure,
  swift_demangler_node_kind_Subscript,
  swift_demangler_node_kind_Suffix,
  swift_demangler_node_kind_ThinFunctionType,
  swift_demangler_node_kind_Tuple,
  swift_demangler_node_kind_TupleElement,
  swift_demangler_node_kind_TupleElementName,
  swift_demangler_node_kind_Type,
  swift_demangler_node_kind_TypeSymbolicReference,
  swift_demangler_node_kind_TypeAlias,
  swift_demangler_node_kind_TypeList,
  swift_demangler_node_kind_TypeMangling,
  swift_demangler_node_kind_TypeMetadata,
  swift_demangler_node_kind_TypeMetadataAccessFunction,
  swift_demangler_node_kind_TypeMetadataCompletionFunction,
  swift_demangler_node_kind_TypeMetadataInstantiationCache,
  swift_demangler_node_kind_TypeMetadataInstantiationFunction,
  swift_demangler_node_kind_TypeMetadataSingletonInitializationCache,
  swift_demangler_node_kind_TypeMetadataDemanglingCache,
  swift_demangler_node_kind_TypeMetadataLazyCache,
  swift_demangler_node_kind_UncurriedFunctionType,
  swift_demangler_node_kind_UnknownIndex,
  swift_demangler_node_kind_Weak,
  swift_demangler_node_kind_Unowned,
  swift_demangler_node_kind_Unmanaged,
  swift_demangler_node_kind_UnsafeAddressor,
  swift_demangler_node_kind_UnsafeMutableAddressor,
  swift_demangler_node_kind_ValueWitness,
  swift_demangler_node_kind_ValueWitnessTable,
  swift_demangler_node_kind_Variable,
  swift_demangler_node_kind_VTableThunk,
  swift_demangler_node_kind_VTableAttribute, // note: old mangling only
  swift_demangler_node_kind_WillSet,
  swift_demangler_node_kind_ReflectionMetadataBuiltinDescriptor,
  swift_demangler_node_kind_ReflectionMetadataFieldDescriptor,
  swift_demangler_node_kind_ReflectionMetadataAssocTypeDescriptor,
  swift_demangler_node_kind_ReflectionMetadataSuperclassDescriptor,
  swift_demangler_node_kind_GenericTypeParamDecl,
  swift_demangler_node_kind_CurryThunk,
  swift_demangler_node_kind_DispatchThunk,
  swift_demangler_node_kind_MethodDescriptor,
  swift_demangler_node_kind_ProtocolRequirementsBaseDescriptor,
  swift_demangler_node_kind_AssociatedConformanceDescriptor,
  swift_demangler_node_kind_DefaultAssociatedConformanceAccessor,
  swift_demangler_node_kind_BaseConformanceDescriptor,
  swift_demangler_node_kind_AssociatedTypeDescriptor,
  swift_demangler_node_kind_ThrowsAnnotation,
  swift_demangler_node_kind_EmptyList,
  swift_demangler_node_kind_FirstElementMarker,
  swift_demangler_node_kind_VariadicMarker,
  swift_demangler_node_kind_OutlinedBridgedMethod,
  swift_demangler_node_kind_OutlinedCopy,
  swift_demangler_node_kind_OutlinedConsume,
  swift_demangler_node_kind_OutlinedRetain,
  swift_demangler_node_kind_OutlinedRelease,
  swift_demangler_node_kind_OutlinedInitializeWithTake,
  swift_demangler_node_kind_OutlinedInitializeWithCopy,
  swift_demangler_node_kind_OutlinedAssignWithTake,
  swift_demangler_node_kind_OutlinedAssignWithCopy,
  swift_demangler_node_kind_OutlinedDestroy,
  swift_demangler_node_kind_OutlinedVariable,
  swift_demangler_node_kind_AssocTypePath,
  swift_demangler_node_kind_LabelList,
  swift_demangler_node_kind_ModuleDescriptor,
  swift_demangler_node_kind_ExtensionDescriptor,
  swift_demangler_node_kind_AnonymousDescriptor,
  swift_demangler_node_kind_AssociatedTypeGenericParamRef,
  swift_demangler_node_kind_SugaredOptional,
  swift_demangler_node_kind_SugaredArray,
  swift_demangler_node_kind_SugaredDictionary,
  swift_demangler_node_kind_SugaredParen,

  // Added in Swift 5.1
  swift_demangler_node_kind_AccessorFunctionReference,
  swift_demangler_node_kind_OpaqueType,
  swift_demangler_node_kind_OpaqueTypeDescriptorSymbolicReference,
  swift_demangler_node_kind_OpaqueTypeDescriptor,
  swift_demangler_node_kind_OpaqueTypeDescriptorAccessor,
  swift_demangler_node_kind_OpaqueTypeDescriptorAccessorImpl,
  swift_demangler_node_kind_OpaqueTypeDescriptorAccessorKey,
  swift_demangler_node_kind_OpaqueTypeDescriptorAccessorVar,
  swift_demangler_node_kind_OpaqueReturnType,
  swift_demangler_node_kind_OpaqueReturnTypeOf,
} swift_demangler_node_kind_t
__attribute__((swift_name("UnsafeSwiftDemanglerNodeKind")));

SWIFT_DEMANGLE_LINKAGE
const char * _Nonnull
swift_demangler_getNodeKindName(swift_demangler_node_kind_t kind)
__attribute__((swift_name("getter:UnsafeSwiftDemanglerNodeKind.unsafeName(self:)")));

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

/// Returns the kind of the node.
SWIFT_DEMANGLE_LINKAGE
swift_demangler_node_kind_t
swift_demangler_getNodeKind(swift_demangler_node_t _Nonnull node)
__attribute__((swift_name("getter:UnsafeSwiftDemanglerNode.kind(self:)")));

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

