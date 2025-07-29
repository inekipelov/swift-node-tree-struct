//
//  NodeTreeTests.swift
//

import XCTest
@testable import NodeTreeStruct

final class NodeTreeTests: XCTestCase {

    // MARK: - Initialization Tests
    
    func testInitWithValueAndNodes() {
        let child1 = NodeTree(value: 2)
        let child2 = NodeTree(value: 3)
        let tree = NodeTree(value: 1, nodes: [child1, child2])
        
        XCTAssertEqual(tree.value, 1)
        XCTAssertEqual(tree.children.count, 2)
        XCTAssertEqual(tree.children[0].value, 2)
        XCTAssertEqual(tree.children[1].value, 3)
    }
    
    func testInitWithValueAndChildrenValues() {
        let tree = NodeTree(value: 1, children: [2, 3, 4])
        
        XCTAssertEqual(tree.value, 1)
        XCTAssertEqual(tree.children.count, 3)
        XCTAssertEqual(tree.children[0].value, 2)
        XCTAssertEqual(tree.children[1].value, 3)
        XCTAssertEqual(tree.children[2].value, 4)
    }
    
    func testInitWithValueOnly() {
        let tree = NodeTree(value: "root")
        
        XCTAssertEqual(tree.value, "root")
        XCTAssertEqual(tree.children.count, 0)
    }
    
    // MARK: - Dynamic Member Lookup Tests
    
    func testDynamicMemberLookupRead() {
        let person = TestPerson(id: "1", name: "John", age: 30)
        let tree = NodeTree(value: person)
        
        XCTAssertEqual(tree.name, "John")
        XCTAssertEqual(tree.age, 30)
        XCTAssertEqual(tree.id, "1")
    }
    
    func testDynamicMemberLookupWrite() {
        let person = TestPerson(id: "1", name: "John", age: 30)
        var tree = NodeTree(value: person)
        
        tree.age = 31
        XCTAssertEqual(tree.age, 31)
        XCTAssertEqual(tree.value.age, 31)
    }

    func testIfLeaf() {
        let leaf = NodeTree(value: 1)
        let nonLeaf = NodeTree(value: 2, children: [3])
        
        XCTAssertTrue(leaf.isLeaf)
        XCTAssertFalse(nonLeaf.isLeaf)
    }

    // MARK: - Traversal Tests
    
    func testDepthFirstTraversal() {
        let tree = createTestTree()
        var visitedValues: [Int] = []
        
        tree.traverse(order: .depthFirst) { value in
            visitedValues.append(value)
            return true
        }
        
        XCTAssertEqual(visitedValues, [1, 2, 5, 6, 3, 4])
    }
    
    func testBreadthFirstTraversal() {
        let tree = createTestTree()
        var visitedValues: [Int] = []
        
        tree.traverse(order: .breadthFirst) { value in
            visitedValues.append(value)
            return true
        }
        
        XCTAssertEqual(visitedValues, [1, 2, 3, 4, 5, 6])
    }
    
    func testTraversalEarlyExit() {
        let tree = createTestTree()
        var visitedValues: [Int] = []
        
        let result = tree.traverse(order: .depthFirst) { value in
            visitedValues.append(value)
            return value != 5 // Stop when we reach 5
        }
        
        XCTAssertFalse(result)
        XCTAssertEqual(visitedValues, [1, 2, 5])
    }
    
    func testFindFirst() {
        let tree = createTestTree()
        
        let result = tree.findFirst { $0 == 5 }
        XCTAssertEqual(result, 5)
        
        let notFound = tree.findFirst { $0 == 10 }
        XCTAssertNil(notFound)
    }
    
    func testFindAll() {
        let tree = NodeTree(value: 1, children: [2, 3, 2, 4, 2])
        
        let results = tree.findAll { $0 == 2 }
        XCTAssertEqual(results, [2, 2, 2])
        
        let notFound = tree.findAll { $0 == 10 }
        XCTAssertEqual(notFound, [])
    }
    
    // MARK: - Collection Tests
    
    func testCollectionProperties() {
        let tree = NodeTree(value: 1, children: [2, 3, 4])
        
        XCTAssertEqual(tree.startIndex, 0)
        XCTAssertEqual(tree.endIndex, 3)
    }
    
    func testSubscriptAccess() {
        var tree = NodeTree(value: 1, children: [2, 3, 4])
        
        XCTAssertEqual(tree[0].value, 2)
        XCTAssertEqual(tree[1].value, 3)
        XCTAssertEqual(tree[2].value, 4)
        
        tree[1] = NodeTree(value: 10)
        XCTAssertEqual(tree[1].value, 10)
    }
    
    func testOptionalSubscript() {
        let tree = NodeTree(value: 1, children: [2, 3])
        
        XCTAssertEqual(tree[optional: 0]?.value, 2)
        XCTAssertEqual(tree[optional: 1]?.value, 3)
        XCTAssertNil(tree[optional: 5])
    }
    
    func testAppendChild() {
        var tree = NodeTree(value: 1)
        
        tree.append(NodeTree(value: 2))
        tree.append(3)
        
        XCTAssertEqual(tree.children.count, 2)
        XCTAssertEqual(tree[0].value, 2)
        XCTAssertEqual(tree[1].value, 3)
    }
    
    func testRemoveAt() {
        var tree = NodeTree(value: 1, children: [2, 3, 4])
        
        let removed = tree.remove(at: 1)
        XCTAssertEqual(removed.value, 3)
        XCTAssertEqual(tree.children.count, 2)
        XCTAssertEqual(tree[0].value, 2)
        XCTAssertEqual(tree[1].value, 4)
    }
    
    func testRemoveAll() {
        var tree = NodeTree(value: 1, children: [2, 3, 4])
        
        tree.removeAll()
        XCTAssertEqual(tree.children.count, 0)
    }
    
    func testRemoveFirst() {
        var tree = NodeTree(value: 1, children: [2, 3, 4])
        
        let removed = tree.removeFirst()
        XCTAssertEqual(removed.value, 2)
        XCTAssertEqual(tree.children.count, 2)
        XCTAssertEqual(tree[0].value, 3)
    }
    
    func testRemoveFirstN() {
        var tree = NodeTree(value: 1, children: [2, 3, 4, 5])
        
        tree.removeFirst(2)
        XCTAssertEqual(tree.children.count, 2)
        XCTAssertEqual(tree[0].value, 4)
        XCTAssertEqual(tree[1].value, 5)
    }
    
    func testRemoveLast() {
        var tree = NodeTree(value: 1, children: [2, 3, 4])
        
        let removed = tree.removeLast()
        XCTAssertEqual(removed.value, 4)
        XCTAssertEqual(tree.children.count, 2)
        XCTAssertEqual(tree[1].value, 3)
    }
    
    func testRemoveLastN() {
        var tree = NodeTree(value: 1, children: [2, 3, 4, 5])
        
        tree.removeLast(2)
        XCTAssertEqual(tree.children.count, 2)
        XCTAssertEqual(tree[0].value, 2)
        XCTAssertEqual(tree[1].value, 3)
    }
    
    // MARK: - Identifiable Tests
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testIdentifiableId() {
        let person = TestPerson(id: "123", name: "John", age: 30)
        let tree = NodeTree(value: person)
        
        XCTAssertEqual(tree.id, "123")
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testIdentifiableSubscript() {
        let person1 = TestPerson(id: "1", name: "John", age: 30)
        let person2 = TestPerson(id: "2", name: "Jane", age: 25)
        let person3 = TestPerson(id: "3", name: "Bob", age: 35)
        
        var tree = NodeTree(value: person1, nodes: [
            NodeTree(value: person2),
            NodeTree(value: person3)
        ])
        
        XCTAssertEqual(tree[id: "2"]?.value.name, "Jane")
        XCTAssertEqual(tree[id: "3"]?.value.name, "Bob")
        XCTAssertNil(tree[id: "999"])
        
        let newPerson = TestPerson(id: "4", name: "Alice", age: 28)
        tree[id: "2"] = NodeTree(value: newPerson)
        XCTAssertEqual(tree[id: "4"]?.value.name, "Alice")
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testRemoveChildById() {
        let person1 = TestPerson(id: "1", name: "John", age: 30)
        let person2 = TestPerson(id: "2", name: "Jane", age: 25)
        let person3 = TestPerson(id: "3", name: "Bob", age: 35)
        
        var tree = NodeTree(value: person1, nodes: [
            NodeTree(value: person2),
            NodeTree(value: person3)
        ])
        
        tree.removeChild(id: "2")
        XCTAssertEqual(tree.children.count, 1)
        XCTAssertEqual(tree[0].value.id, "3")
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testFindValueById() {
        let tree = createIdentifiableTestTree()
        
        let found = tree.findValue(id: "2")
        XCTAssertEqual(found?.name, "Jane")
        
        let notFound = tree.findValue(id: "999")
        XCTAssertNil(notFound)
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testFindNodeById() {
        let tree = createIdentifiableTestTree()
        
        let found = tree.findNode(id: "2")
        XCTAssertEqual(found?.value.name, "Jane")
        
        let foundRoot = tree.findNode(id: "1")
        XCTAssertEqual(foundRoot?.value.name, "John")
        
        let notFound = tree.findNode(id: "999")
        XCTAssertNil(notFound)
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testAppendChildToNodeById() {
        var tree = createIdentifiableTestTree()
        
        // Initial state: John (id: "1") has children Jane (id: "2") and Bob (id: "3")
        XCTAssertEqual(tree.children.count, 2)
        XCTAssertEqual(tree.children[0].value.id, "2") // Jane
        XCTAssertEqual(tree.children[1].value.id, "3") // Bob
        
        // Append a new child to the root node (John)
        let newPerson1 = TestPerson(id: "4", name: "Alice", age: 28)
        let newChild1 = NodeTree(value: newPerson1)
        tree.append(newChild1, to: "1")
        
        XCTAssertEqual(tree.children.count, 3)
        XCTAssertEqual(tree.children[2].value.id, "4")
        XCTAssertEqual(tree.children[2].value.name, "Alice")
        
        // Append a new child to Jane's node
        let newPerson2 = TestPerson(id: "5", name: "Charlie", age: 32)
        let newChild2 = NodeTree(value: newPerson2)
        tree.append(newChild2, to: "2")
        
        XCTAssertEqual(tree.children[0].children.count, 1)
        XCTAssertEqual(tree.children[0].children[0].value.id, "5")
        XCTAssertEqual(tree.children[0].children[0].value.name, "Charlie")
        
        // Try to append to non-existent node - should not crash but also not add anything
        let newPerson3 = TestPerson(id: "6", name: "David", age: 40)
        let newChild3 = NodeTree(value: newPerson3)
        tree.append(newChild3, to: "999") // Non-existent ID
        
        // Verify the tree structure remains unchanged except for the successful additions
        XCTAssertEqual(tree.children.count, 3)
        XCTAssertEqual(tree.children[0].children.count, 1)
        XCTAssertEqual(tree.children[1].children.count, 0) // Bob should still have no children
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testAppendValueToNodeById() {
        var tree = createIdentifiableTestTree()
        
        // Initial state: John (id: "1") has children Jane (id: "2") and Bob (id: "3")
        XCTAssertEqual(tree.children.count, 2)
        
        // Append a new value to the root node (John)
        let newPerson1 = TestPerson(id: "4", name: "Alice", age: 28)
        tree.append(newPerson1, to: "1")
        
        XCTAssertEqual(tree.children.count, 3)
        XCTAssertEqual(tree.children[2].value.id, "4")
        XCTAssertEqual(tree.children[2].value.name, "Alice")
        XCTAssertEqual(tree.children[2].value.age, 28)
        
        // Append a new value to Jane's node
        let newPerson2 = TestPerson(id: "5", name: "Charlie", age: 32)
        tree.append(newPerson2, to: "2")
        
        XCTAssertEqual(tree.children[0].children.count, 1)
        XCTAssertEqual(tree.children[0].children[0].value.id, "5")
        XCTAssertEqual(tree.children[0].children[0].value.name, "Charlie")
        XCTAssertEqual(tree.children[0].children[0].value.age, 32)
        
        // Append to Bob's node
        let newPerson3 = TestPerson(id: "6", name: "David", age: 40)
        tree.append(newPerson3, to: "3")
        
        XCTAssertEqual(tree.children[1].children.count, 1)
        XCTAssertEqual(tree.children[1].children[0].value.id, "6")
        XCTAssertEqual(tree.children[1].children[0].value.name, "David")
        XCTAssertEqual(tree.children[1].children[0].value.age, 40)
        
        // Try to append to non-existent node - should not crash but also not add anything
        let newPerson4 = TestPerson(id: "7", name: "Eve", age: 35)
        tree.append(newPerson4, to: "999") // Non-existent ID
        
        // Verify the tree structure remains unchanged except for the successful additions
        XCTAssertEqual(tree.children.count, 3)
        XCTAssertEqual(tree.children[0].children.count, 1) // Jane has 1 child
        XCTAssertEqual(tree.children[1].children.count, 1) // Bob has 1 child
        XCTAssertEqual(tree.children[2].children.count, 0) // Alice has no children
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testAppendToNestedNode() {
        // Create a deeper tree structure for testing nested append operations
        let person1 = TestPerson(id: "1", name: "Root", age: 50)
        let person2 = TestPerson(id: "2", name: "Child1", age: 30)
        let person3 = TestPerson(id: "3", name: "Child2", age: 25)
        let person4 = TestPerson(id: "4", name: "Grandchild", age: 10)
        
        let grandchild = NodeTree(value: person4)
        let child1 = NodeTree(value: person2, nodes: [grandchild])
        let child2 = NodeTree(value: person3)
        var tree = NodeTree(value: person1, nodes: [child1, child2])
        
        // Append to the grandchild node
        let newPerson = TestPerson(id: "5", name: "GreatGrandchild", age: 5)
        tree.append(newPerson, to: "4")
        
        // Verify the structure
        let foundGrandchild = tree.findNode(id: "4")
        XCTAssertNotNil(foundGrandchild)
        XCTAssertEqual(foundGrandchild?.children.count, 1)
        XCTAssertEqual(foundGrandchild?.children[0].value.id, "5")
        XCTAssertEqual(foundGrandchild?.children[0].value.name, "GreatGrandchild")
    }
    
    // MARK: - Codable Tests
    
    func testCodableEncoding() throws {
        let tree = createCodableTestTree()
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(tree)
        
        XCTAssertFalse(data.isEmpty)
    }
    
    func testCodableDecoding() throws {
        let tree = createCodableTestTree()
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(tree)
        
        let decoder = JSONDecoder()
        let decodedTree = try decoder.decode(NodeTree<TestPerson>.self, from: data)
        
        XCTAssertEqual(decodedTree.value.name, tree.value.name)
        XCTAssertEqual(decodedTree.children.count, tree.children.count)
        XCTAssertEqual(decodedTree[0].value.name, tree[0].value.name)
    }
    
    // MARK: - Equatable Tests
    
    func testEquality() {
        let tree1 = NodeTree(value: 1, children: [2, 3])
        let tree2 = NodeTree(value: 1, children: [2, 3])
        let tree3 = NodeTree(value: 1, children: [2, 4])
        let tree4 = NodeTree(value: 2, children: [2, 3])
        
        XCTAssertEqual(tree1, tree2)
        XCTAssertNotEqual(tree1, tree3)
        XCTAssertNotEqual(tree1, tree4)
    }
    
    func testEqualityWithComplexStructure() {
        let tree1 = createTestTree()
        let tree2 = createTestTree()
        
        XCTAssertEqual(tree1, tree2)
        
        var tree3 = createTestTree()
        tree3.append(7)
        
        XCTAssertNotEqual(tree1, tree3)
    }
    
    // MARK: - Hashable Tests
    
    func testHashable() {
        let tree1 = NodeTree(value: 1, children: [2, 3])
        let tree2 = NodeTree(value: 1, children: [2, 3])
        let tree3 = NodeTree(value: 1, children: [2, 4])
        
        XCTAssertEqual(tree1.hashValue, tree2.hashValue)
        XCTAssertNotEqual(tree1.hashValue, tree3.hashValue)
    }
    
    func testHashableInSet() {
        let tree1 = NodeTree(value: 1, children: [2, 3])
        let tree2 = NodeTree(value: 1, children: [2, 3])
        let tree3 = NodeTree(value: 1, children: [2, 4])
        
        let set: Set<NodeTree<Int>> = [tree1, tree2, tree3]
        XCTAssertEqual(set.count, 2) // tree1 and tree2 should be considered the same
    }
    
    // MARK: - Map Tests
    
    func testMap() {
        let tree = NodeTree(value: 1, children: [2, 3, 4])
        
        let mappedTree = tree.map { $0 * 2 }
        
        XCTAssertEqual(mappedTree.value, 2)
        XCTAssertEqual(mappedTree.children.count, 3)
        XCTAssertEqual(mappedTree[0].value, 4)
        XCTAssertEqual(mappedTree[1].value, 6)
        XCTAssertEqual(mappedTree[2].value, 8)
    }
    
    func testMapWithComplexStructure() {
        let tree = createTestTree()
        
        let stringTree = tree.map { "Value: \($0)" }
        
        XCTAssertEqual(stringTree.value, "Value: 1")
        XCTAssertEqual(stringTree[0].value, "Value: 2")
        XCTAssertEqual(stringTree[0][0].value, "Value: 5")
        XCTAssertEqual(stringTree[0][1].value, "Value: 6")
    }
    
    func testMapWithThrowingTransform() {
        let tree = NodeTree(value: "1", children: ["2", "abc", "4"])
        
        XCTAssertThrowsError(try tree.map { str -> Int in
            guard let int = Int(str) else {
                throw NSError(domain: "TestError", code: 1)
            }
            return int
        })
    }
    
    func testMapWithKeyPath() {
        let person1 = TestPerson(id: "1", name: "John", age: 30)
        let person2 = TestPerson(id: "2", name: "Jane", age: 25)
        let person3 = TestPerson(id: "3", name: "Bob", age: 35)
        let person4 = TestPerson(id: "4", name: "Alice", age: 28)
        
        let tree = NodeTree(value: person1, nodes: [
            NodeTree(value: person2),
            NodeTree(value: person3, nodes: [
                NodeTree(value: person4)
            ])
        ])
        
        // Test mapping using KeyPath for name
        let nameTree = tree.map(\.name)
        XCTAssertEqual(nameTree.value, "John")
        XCTAssertEqual(nameTree.children.count, 2)
        XCTAssertEqual(nameTree[0].value, "Jane")
        XCTAssertEqual(nameTree[1].value, "Bob")
        XCTAssertEqual(nameTree[1][0].value, "Alice")
        
        // Test mapping using KeyPath for age
        let ageTree = tree.map(\.age)
        XCTAssertEqual(ageTree.value, 30)
        XCTAssertEqual(ageTree.children.count, 2)
        XCTAssertEqual(ageTree[0].value, 25)
        XCTAssertEqual(ageTree[1].value, 35)
        XCTAssertEqual(ageTree[1][0].value, 28)
        
        // Test mapping using KeyPath for id
        let idTree = tree.map(\.id)
        XCTAssertEqual(idTree.value, "1")
        XCTAssertEqual(idTree.children.count, 2)
        XCTAssertEqual(idTree[0].value, "2")
        XCTAssertEqual(idTree[1].value, "3")
        XCTAssertEqual(idTree[1][0].value, "4")
    }
    
    func testMapKeyPathWithComplexStruct() {
        let ceo = Employee(
            name: "CEO",
            address: Address(street: "Main St", city: "New York"),
            salary: 100000
        )
        let manager = Employee(
            name: "Manager",
            address: Address(street: "Oak Ave", city: "Boston"),
            salary: 80000
        )
        let developer = Employee(
            name: "Developer",
            address: Address(street: "Pine Rd", city: "Austin"),
            salary: 75000
        )
        
        let orgChart = NodeTree(value: ceo, nodes: [
            NodeTree(value: manager, nodes: [
                NodeTree(value: developer)
            ])
        ])
        
        // Test mapping nested KeyPath
        let cityTree = orgChart.map(\.address.city)
        XCTAssertEqual(cityTree.value, "New York")
        XCTAssertEqual(cityTree[0].value, "Boston")
        XCTAssertEqual(cityTree[0][0].value, "Austin")
        
        // Test mapping salary
        let salaryTree = orgChart.map(\.salary)
        XCTAssertEqual(salaryTree.value, 100000)
        XCTAssertEqual(salaryTree[0].value, 80000)
        XCTAssertEqual(salaryTree[0][0].value, 75000)
    }

    func testFlatMap() {
        let tree = NodeTree(value: 1, children: [2, 3, 4])
        let flatMappedValues = tree.flatMap { $0 * 2 }
        XCTAssertEqual(flatMappedValues, [2, 4, 6, 8])
    }

    func testFlatMapWithKeyPath() {
        let ceo = Employee(
            name: "CEO",
            address: Address(street: "Main St", city: "New York"),
            salary: 100000
        )
        let manager = Employee(
            name: "Manager",
            address: Address(street: "Oak Ave", city: "Boston"),
            salary: 80000
        )
        let developer = Employee(
            name: "Developer",
            address: Address(street: "Pine Rd", city: "Austin"),
            salary: 75000
        )

        let orgChart = NodeTree(value: ceo, nodes: [
            NodeTree(value: manager, nodes: [
                NodeTree(value: developer)
            ])
        ])
        let flatMappedCities = orgChart.flatMap(\.address.city)
        XCTAssertEqual(flatMappedCities, ["New York", "Boston", "Austin"])
        let flatMappedSalaries = orgChart.flatMap(\.salary)
        XCTAssertEqual(flatMappedSalaries, [100000, 80000, 75000])
    }


    // MARK: - Helper Methods
    
    private func createTestTree() -> NodeTree<Int> {
        /*
         Tree structure:
              1
            / | \
           2  3  4
          / \
         5   6
        */
        let leaf5 = NodeTree(value: 5)
        let leaf6 = NodeTree(value: 6)
        let node2 = NodeTree(value: 2, nodes: [leaf5, leaf6])
        let leaf3 = NodeTree(value: 3)
        let leaf4 = NodeTree(value: 4)
        
        return NodeTree(value: 1, nodes: [node2, leaf3, leaf4])
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    private func createIdentifiableTestTree() -> NodeTree<TestPerson> {
        let person1 = TestPerson(id: "1", name: "John", age: 30)
        let person2 = TestPerson(id: "2", name: "Jane", age: 25)
        let person3 = TestPerson(id: "3", name: "Bob", age: 35)
        
        return NodeTree(value: person1, nodes: [
            NodeTree(value: person2),
            NodeTree(value: person3)
        ])
    }
    
    private func createCodableTestTree() -> NodeTree<TestPerson> {
        let person1 = TestPerson(id: "1", name: "John", age: 30)
        let person2 = TestPerson(id: "2", name: "Jane", age: 25)
        
        return NodeTree(value: person1, nodes: [
            NodeTree(value: person2)
        ])
    }
}
