//
//  NodeTree.swift
//

import Foundation
import CodableAdvance
import Collections
import CollectionAdvance

@dynamicMemberLookup
public struct NodeTree<V> {
    public typealias Element = NodeTree<V>
    public typealias Index = Int
    
    public var value: V
    public private(set) var children: [NodeTree<V>] = []
    
    public init(value: V, nodes children: [NodeTree<V>]) {
        self.value = value
        self.children = children
    }
    
    public init(value: V, children: [V] = []) {
        self.value = value
        self.children = children.map { NodeTree(value: $0) }
    }
    
    
    // MARK: - Dynamic Member Lookup
    public subscript<T>(dynamicMember keyPath: KeyPath<V, T>) -> T {
        self.value[keyPath: keyPath]
    }
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<V, T>) -> T {
        get { self.value[keyPath: keyPath] }
        set { self.value[keyPath: keyPath] = newValue }
    }
}

// MARK: - Traversal
public extension NodeTree {
    enum TraversalOrder {
        case depthFirst
        case breadthFirst
    }
    
    /// Traverses the tree, allowing early exit if `visit` returns false.
    @discardableResult
    func traverse(order: TraversalOrder = .depthFirst, _ visit: (V) throws -> Bool) rethrows -> Bool {
        switch order {
        case .depthFirst:
            return try traverseDepthFirst(visit)
        case .breadthFirst:
            return try traverseBreadthFirst(visit)
        }
    }
    
    /// Finds the first value matching the predicate.
    func findFirst(order: TraversalOrder = .depthFirst, where predicate: (V) throws -> Bool) rethrows -> V? {
        var result: V?
        try traverse(order: order) { value in
            if try predicate(value) {
                result = value
                return false
            }
            return true
        }
        return result
    }
    
    /// Finds all values matching the predicate.
    func findAll(order: TraversalOrder = .depthFirst ,where predicate: (V) throws -> Bool) rethrows -> [V] {
        var results: [V] = []
        try traverse(order: order) { value in
            if try predicate(value) {
                results.append(value)
            }
            return true
        }
        return results
    }
}

private extension NodeTree {
    /// Depth-first traversal with early exit.
    func traverseDepthFirst(_ visit: (V) throws -> Bool) rethrows -> Bool {
        if try !visit(value) { return false }
        for child in children {
            if try !child.traverseDepthFirst(visit) {
                return false
            }
        }
        return true
    }
    
    /// Breadth-first traversal with early exit.
    func traverseBreadthFirst(_ visit: (V) throws -> Bool) rethrows -> Bool {
        var queue: Deque<NodeTree<V>> = [self]
        
        while !queue.isEmpty {
            let node = queue.removeFirst()
            if try !visit(node.value) {
                return false
            }
            queue.append(contentsOf: node.children)
        }
        return true
    }
}

// MARK: - Collection
public extension NodeTree {
    var startIndex: Int { children.startIndex }
    var endIndex: Int { children.endIndex }
    var isEmpty: Bool { children.isEmpty }
    var count: Int { children.count }
    
    subscript(index: Int) -> NodeTree<V> {
        get { children[index] }
        mutating set { children[index] = newValue }
    }
    
    mutating func append(_ child: NodeTree<V>) {
        self.children.append(child)
    }
    mutating func append(_ value: V) {
        self.children.append(NodeTree(value: value))
    }
    
    @discardableResult
    mutating func remove(at index: Int) -> Element {
        self.children.remove(at: index)
    }
    
    mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        self.children.removeAll(keepingCapacity: keepCapacity)
    }
    
    mutating func removeFirst() -> Element {
        self.children.removeFirst()
    }
    mutating func removeFirst(_ n: Int) {
        self.children.removeFirst(n)
    }
    mutating func removeLast() -> Element {
        self.children.removeLast()
    }
    mutating func removeLast(_ n: Int) {
        self.children.removeLast(n)
    }
    
    subscript(optional index: Int) -> NodeTree<V>? {
        self.children[optional: index]
    }
}

// MARK: - Identifiable
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NodeTree: Identifiable where V: Identifiable {
    public var id: V.ID { value.id }
    
    public subscript(id elementID: V.ID) -> NodeTree<V>? {
        mutating get { children[id: elementID] }
        mutating set { children[id: elementID] = newValue }
    }
    
    public mutating func removeChild(id: V.ID) {
        self.children.remove(id: id)
    }
    
    public func findValue(id: V.ID) -> V? {
        return findFirst {
            $0.id == id
        }
    }
    public func findNode(id: V.ID) -> NodeTree<V>? {
        if self.id == id {
            return self
        }
        return children.map { $0.findNode(id: id) }.compactMap { $0 }.first
    }
    public mutating func append(_ child: NodeTree<V>, to id: V.ID) {
        let isContained = findNode(id: id) != nil
        guard isContained else { return }
        
        if self.id == id {
            self.append(child)
        } else {
            self.children = self.children.map {
                var childNode = $0
                childNode.append(child, to: id)
                return childNode
            }
        }
    }
    public mutating func append(_ value: V, to id: V.ID) {
        let isContained = findNode(id: id) != nil
        guard isContained else { return }
        
        if self.id == id {
            self.append(value)
        } else {
            self.children = self.children.map {
                var childNode = $0
                childNode.append(value, to: id)
                return childNode
            }
        }
    }
}
    
// MARK: - Codable
private extension NodeTree {
    enum CodingKeys: String, CodingKey {
        case value
        case children
    }
}
extension NodeTree: Encodable where V: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(children, forKey: .children)
    }
}

extension NodeTree: Decodable where V: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(V.self, forKey: .value)
        self.children = try container
            .compactDecode(NodeTree<V>.self, forKey: .children)
    }
}
