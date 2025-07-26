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

    func flatMap<U>(order: TraversalOrder = .depthFirst, _ transform: (V) throws -> U) rethrows -> [U] {
        var results: [U] = []
        try traverse(order: order) { value in
            try results.append(transform(value))
            return true
        }
        return results
    }
    func flatMap<U>(order: TraversalOrder = .depthFirst, _ keyPath: KeyPath<V, U>) -> [U] {
        var results: [U] = []
        traverse(order: order) { value in
            results.append(value[keyPath: keyPath])
            return true
        }
        return results
    }
}
