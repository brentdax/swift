add_swift_copy_headers_target(copy_swiftDemangle_headers
  BUILD "${SWIFTLIB_DIR}/SwiftDemangle"
  INSTALL "lib/swift/SwiftDemangle"
  COMPONENT compiler

  MangleHack.h
  module.modulemap
  Platform.h
  SwiftDemangle.h
  )
