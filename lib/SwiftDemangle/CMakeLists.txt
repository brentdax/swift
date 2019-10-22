add_swift_target_library(swiftDemangle SHARED
  LINK_LIBRARIES swiftDemangling
  DEPENDS copy_swiftDemangle_headers
  TARGET_SDKS "${SWIFT_HOST_VARIANT_SDK}"
  COMPILE_DEFINITIONS LLVM_DISABLE_ABI_BREAKING_CHECKS_ENFORCING=1
  INSTALL
  INSTALL_IN_COMPONENT compiler
  SwiftDemangle.cpp
  MangleHack.cpp)
