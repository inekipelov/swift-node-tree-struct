//
//  NodeTree+Equatable.swift
//

extension NodeTree: Equatable where V: Equatable {
    public static func == (lhs: NodeTree, rhs: NodeTree) -> Bool {
        lhs.value == rhs.value && lhs.children == rhs.children
    }
}
