//
//  TestPerson.swift
//  swift-node-tree-struct
//
//  Created by Roman Niekipielov on 26.07.2025.
//

struct TestPerson: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let name: String
    var age: Int
}
