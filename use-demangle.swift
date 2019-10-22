import Demangle
let demangler = Demangler()

func printOut(_ node: Node, depth: Int = 0) {
  print(String(repeating: " ", count: depth * 2), terminator: "")
  print(node.mangled, node.kind, terminator: " ")
  switch node.payload {
  case .text(let string):
    print(string.debugDescription)
  case .index(let i):
    print(i)
  case .children(let children):
    print()
    for child in children {
      printOut(child, depth: depth + 1)
    }
  }
}

//for arg in CommandLine.arguments.dropFirst() {
  let node = demangler.node(fromSymbol: "$s5JetUI14LayoutTextViewPAAE22estimatedNumberOfLines4fromSiSo14JUMeasurementsV_tFTf4xn_n")!
  printOut(node)
  node.dump()
//}
