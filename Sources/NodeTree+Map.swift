//
//  NodeTree+Map.swift
//

public extension NodeTree {
    func map<U>(_ transform: (V) throws -> U) rethrows -> NodeTree<U> {
        let newValue = try transform(self.value)
        let newNodes = try children.map { try $0.map(transform) }
        return NodeTree<U>(value: newValue, nodes: newNodes)
    }
    
    func map<U>(_ keyPath: KeyPath<V, U>) -> NodeTree<U> {
        let newValue = self.value[keyPath: keyPath]
        let newNodes = self.children.map { $0.map(keyPath) }
        return NodeTree<U>(value: newValue, nodes: newNodes)
    }
}
