set(sources
  Demangler.cpp
  Context.cpp
  ManglingUtils.cpp
  NodeDumper.cpp
  NodePrinter.cpp
  OldDemangler.cpp
  OldRemangler.cpp
  Punycode.cpp
  Remangler.cpp)

add_swift_host_library(swiftDemangling STATIC ${sources})
target_compile_definitions(swiftDemangling PRIVATE
  LLVM_DISABLE_ABI_BREAKING_CHECKS_ENFORCING=1)

add_swift_target_library(swiftDemangling STATIC
  TARGET_SDKS "${SWIFT_HOST_VARIANT_SDK}"
  COMPILE_DEFINITIONS LLVM_DISABLE_ABI_BREAKING_CHECKS_ENFORCING=1
  INSTALL_IN_COMPONENT compiler
  ${sources})
