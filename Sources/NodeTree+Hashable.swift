//
//  NodeTree+Hashable.swift
//

extension NodeTree: Hashable where V: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(children)
    }
}
