@_exported import SwiftDemangle

public struct Node {
  let demangler: Demangler
  public let underlying: UnsafeNode

  public var kind: NodeKind { underlying.kind }

  public var mangled: String {
    switch kind {
    case .dependentPseudogenericSignature, .functionSignatureSpecializationParamKind, .functionSignatureSpecializationParamPayload, .genericSpecializationParam, .index, .unknownIndex, .implFunctionAttribute, .implParameter, .implResult, .implErrorResult:
      return ""
    default:
      return demangler.mangled.cache(underlying) {
        String(cString: demangler.underlying.unsafeSymbol(from: underlying))
      }
    }
  }

  public func dump() { underlying.dump() }
}

extension Node {
  public enum Payload {
    case text(String)
    case index(Int)
    indirect case children(Children)

    internal init(node: Node) {
      switch node.underlying.payloadKind {
      case .text:
        self = .text(
          node.demangler.text.cache(node.underlying) {
            String(cString: node.demangler.underlying
                .unsafeText(from: node.underlying))
          }
        )
      case .index:
        self = .index(Int(node.underlying.index))
      case .children:
        self = .children(Children(node: node))
      @unknown default:
        fatalError("Unknown payloadKind \(node.underlying.payloadKind)")
      }
    }
  }

  public var payload: Payload {
    demangler.payloads.cache(underlying) { Payload(node: self) }
  }
}

extension Node {
  public struct Children: RandomAccessCollection {
    let node: Node

    public let startIndex = 0
    public var endIndex: Int { node.underlying.count }

    public subscript(_ i: Int) -> Node {
      Node(demangler: node.demangler, underlying: node.underlying.child(at: i))
    }
  }
}

extension NodeKind: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    String(cString: unsafeName)
  }

  public var debugDescription: String {
    "SwiftDemangle.NodeKind.\(self)"
  }
}
