@_exported import SwiftDemangle
import Darwin

public class Demangler {
  public let underlying = UnsafeDemangler()

  public init() {}

  deinit {
    underlying.deallocate()
    for (_, pointer) in strings {
      pointer.deallocate()
    }
  }

  public func node(fromSymbol symbol: String) -> Node? {
    let buffer = strings.cache(symbol) { strdup(symbol)! }
    return underlying.node(fromSymbol: buffer).map {
      Node(demangler: self, underlying: $0)
    }
  }

  var payloads: [UnsafeNode: Node.Payload] = [:]
  var mangled: [UnsafeNode: String] = [:]
  var text: [UnsafeNode: String] = [:]
  var strings: [String: UnsafeMutablePointer<Int8>] = [:]
}

extension Dictionary {
  mutating func cache(_ key: Key, makeValue: () -> Value) -> Value {
    if let value = self[key] { return value }
    let newValue = makeValue()
    self[key] = newValue
    return newValue
  }
}
