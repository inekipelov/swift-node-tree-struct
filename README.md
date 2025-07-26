# NodeTreeStruct

[![Swift Version](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Swift Tests](https://github.com/inekipelov/swift-node-tree-struct/actions/workflows/swift.yml/badge.svg)](https://github.com/inekipelov/swift-node-tree-struct/actions/workflows/swift.yml)  
[![iOS](https://img.shields.io/badge/iOS-9.0+-blue.svg)](https://developer.apple.com/ios/)
[![macOS](https://img.shields.io/badge/macOS-10.13+-white.svg)](https://developer.apple.com/macos/)
[![tvOS](https://img.shields.io/badge/tvOS-9.0+-black.svg)](https://developer.apple.com/tvos/)
[![watchOS](https://img.shields.io/badge/watchOS-2.0+-orange.svg)](https://developer.apple.com/watchos/)

A powerful, value-type, generic tree node structure for type-safe hierarchical data management in Swift. Built with modern Swift features including dynamic member lookup, comprehensive protocol conformances, and seamless integration with Swift's collection ecosystem.

## Complete API Reference

### Core Structure

#### Initialization
- `init(value: V, nodes children: [NodeTree<V>])` - Initialize with value and existing node children
- `init(value: V, children: [V] = [])` - Initialize with value and child values (automatically wrapped in nodes)

#### Dynamic Member Lookup
- `subscript(dynamicMember keyPath: KeyPath<V, T>) -> T` - Read access to value properties
- `subscript(dynamicMember keyPath: WritableKeyPath<V, T>) -> T` - Read/write access to value properties

### Tree Traversal

#### Traversal Methods
- `traverse(order: TraversalOrder = .depthFirst, _ visit: (V) throws -> Bool) -> Bool` - Traverse tree with early exit support
- `TraversalOrder.depthFirst` - Visit current node, then children recursively
- `TraversalOrder.breadthFirst` - Visit all nodes at current level before moving to next level

#### Search Operations
- `findFirst(where predicate: (V) throws -> Bool) -> V?` - Find first value matching predicate
- `findAll(where predicate: (V) throws -> Bool) -> [V]` - Find all values matching predicate

### Collection Interface

#### Index-based Access
- `subscript(index: Int) -> NodeTree<V>` - Get/set child nodes by index
- `subscript(optional index: Int) -> NodeTree<V>?` - Safe subscript with nil for out-of-bounds
- `startIndex: Int` - First valid child index
- `endIndex: Int` - One past last valid child index

#### Child Manipulation
- `append(_ child: NodeTree<V>)` - Add existing node as child
- `append(_ value: V)` - Create and add new child node with value
- `remove(at index: Int) -> Element` - Remove and return child at index
- `removeAll(keepingCapacity: Bool = false)` - Remove all children
- `removeFirst() -> Element` - Remove and return first child
- `removeFirst(_ n: Int)` - Remove first n children
- `removeLast() -> Element` - Remove and return last child
- `removeLast(_ n: Int)` - Remove last n children

### Identifiable Support (iOS 13.0+, macOS 10.15+, tvOS 13.0+, watchOS 6.0+)

#### ID-based Operations (when V: Identifiable)
- `id: V.ID` - Access to the node's value ID
- `subscript(id elementID: V.ID) -> NodeTree<V>?` - Get/set/remove children by ID
- `removeChild(id: V.ID)` - Remove child with specified ID
- `findValue(id: V.ID) -> V?` - Find value anywhere in tree by ID
- `findNode(id: V.ID) -> NodeTree<V>?` - Find node anywhere in tree by ID
- `append(_ child: NodeTree<V>, to id: V.ID)` - Add existing node as child to node with specified ID
- `append(_ value: V, to id: V.ID)` - Create and add new child node to node with specified ID

### Functional Programming

#### Transformation
- `map<U>(_ transform: (V) throws -> U) -> NodeTree<U>` - Transform all values in tree structure
- `map<U>(_ keyPath: KeyPath<V, U>) -> NodeTree<U>` - Transform values using KeyPath for property extraction

### Protocol Conformances

#### Equatable (when V: Equatable)
- `==` operator for structural equality comparison
- Compares both values and entire subtree structure

#### Hashable (when V: Hashable)
- Full hash implementation including all child nodes
- Enables use in Sets and as Dictionary keys

#### Codable (when V: Codable)
- Full JSON/PropertyList encoding and decoding support
- Preserves complete tree structure
- Uses `CodableAdvance` for robust error handling

## Usage Examples

### Basic Tree Creation

```swift
// Simple tree with Int values
let tree = NodeTree(value: 1, children: [2, 3, 4])

// Tree with custom objects
struct Person: Equatable, Hashable, Identifiable {
    let id: String
    let name: String
    var age: Int
}

let family = NodeTree(
    value: Person(id: "1", name: "Parent", age: 45),
    nodes: [
        NodeTree(value: Person(id: "2", name: "Child1", age: 15)),
        NodeTree(value: Person(id: "3", name: "Child2", age: 12))
    ]
)
```

### Dynamic Member Lookup

```swift
// Access value properties directly on the tree
print(family.name)     // "Parent"
print(family.age)      // 45

// Modify value properties
family.age = 46
```

### Tree Traversal

```swift
// Depth-first traversal
tree.traverse(order: .depthFirst) { value in
    print(value)
    return true  // Continue traversal
}

// Early exit on condition
tree.traverse { value in
    print(value)
    return value != 3  // Stop when we find 3
}

// Find operations
let found = tree.findFirst { $0 > 2 }        // Returns first value > 2
let allLarge = tree.findAll { $0 > 2 }       // Returns all values > 2
```

### Collection Operations

```swift
var tree = NodeTree(value: "root")

// Add children
tree.append("child1")
tree.append(NodeTree(value: "child2"))

// Access children
print(tree[0].value)           // "child1"
print(tree[optional: 5])       // nil (safe access)

// Remove children
let removed = tree.remove(at: 0)
tree.removeFirst()
tree.removeLast()
```

### Identifiable Operations (iOS 13.0+, macOS 10.15+, tvOS 13.0+, watchOS 6.0+)

```swift
// ID-based access
if let child = family[id: "2"] {
    child.age += 1
}

// Remove by ID
family.removeChild(id: "3")

// Find anywhere in tree
let person = family.findValue(id: "2")
let node = family.findNode(id: "2")

// Add children to specific nodes by ID
let newChild = Person(id: "4", name: "Grandchild", age: 5)

// Add a new child node to the person with ID "2"
family.append(newChild, to: "2")

// Add an existing node to the person with ID "1" (root)
let adoptedChild = NodeTree(value: Person(id: "5", name: "Adopted", age: 10))
family.append(adoptedChild, to: "1")
```

### Functional Transformations

```swift
// Transform all values in tree
let ageTree = family.map { $0.age }
let nameTree = family.map { $0.name.uppercased() }

// Preserve structure while transforming values
let stringTree = tree.map { "Value: \($0)" }

// Extract properties using KeyPath
let ageTreeKeyPath = family.map(\.age)
let nameTreeKeyPath = family.map(\.name)
let idTreeKeyPath = family.map(\.id)

// Extract nested properties
struct Address { let city: String }
struct Employee { let name: String; let address: Address }
let employeeTree = NodeTree(value: Employee(name: "John", address: Address(city: "NYC")))
let cityTree = employeeTree.map(\.address.city)
```

### Codable Support

```swift
// Encode to JSON
let encoder = JSONEncoder()
let data = try encoder.encode(family)

// Decode from JSON
let decoder = JSONDecoder()
let restoredFamily = try decoder.decode(NodeTree<Person>.self, from: data)
```

## Performance Characteristics

### Traversal Performance
- **Depth-First**: O(n) time, O(h) space where h is tree height
- **Breadth-First**: O(n) time, O(w) space where w is maximum width
- **Early Exit**: Optimal - stops immediately when condition is met

### Collection Operations
- **Index Access**: O(1) for direct children
- **ID-based Access**: O(n) in worst case (searches entire subtree)
- **Safe Subscript**: O(1) with bounds checking

### Memory Efficiency
- **Value Semantics**: Copy-on-write for efficient memory usage
- **Generic Design**: No boxing overhead for value types
- **Structural Sharing**: Immutable operations enable sharing when possible

## Best Practices

1. **Use Dynamic Member Lookup** for clean, readable access to value properties
2. **Leverage Identifiable Support** for ID-based operations instead of manual searching
3. **Choose Appropriate Traversal Order** based on your use case:
   - Depth-first for hierarchical processing
   - Breadth-first for level-by-level operations
4. **Use Safe Subscripting** when index validity is uncertain
5. **Implement Required Protocols** on your value type for full feature access:
   - `Equatable` for structural comparison
   - `Hashable` for Set/Dictionary usage
   - `Identifiable` for ID-based operations
   - `Codable` for persistence

## Installation

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/inekipelov/swift-node-tree-struct.git", from: "0.1.0")
]
```

Then add the dependency to your target:

```swift
targets: [
    .target(name: "YourTarget", dependencies: ["NodeTreeStruct"]),
]
```
