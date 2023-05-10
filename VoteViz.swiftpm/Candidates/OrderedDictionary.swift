//
//  OrderedDictionary.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 17/04/2023.
//

struct OrderedDictionary<Key: Hashable, Value> {
    var underlyingDictionary: [Key: Value]
    var underlyingArray: [Key]
}

extension OrderedDictionary {
    var keys: [Key] {underlyingArray}
    var count: Int {underlyingArray.count}

    func getValues() -> [Value] {
        underlyingArray.map { underlyingDictionary[$0]! }
    }
}

extension OrderedDictionary {
    init(_ array: [Value], key: (Value) -> Key) {
        let keyValuePairs = array.map { (key: key($0), value: $0) }
        self.underlyingDictionary = keyValuePairs.reduce(into: [Key: Value]()) { $0[$1.key] = $1.value }
        precondition(underlyingDictionary.count == array.count, "Attempted to create OrderedDictionary with duplicate keys")
        self.underlyingArray = keyValuePairs.map(\.key)
    }
}

extension OrderedDictionary {
    subscript(key: Key) -> Value? {
        get {
            underlyingDictionary[key]
        }
        set(newValue) {
            underlyingDictionary[key] = newValue
        }
    }

    subscript(index: Int) -> Value? {
        get {
            underlyingDictionary[underlyingArray[index]]
        }
        set(newValue) {
            underlyingDictionary[underlyingArray[index]] = newValue
        }
    }

    subscript(index: Int) -> Key {
        underlyingArray[index]
    }
}

extension OrderedDictionary {
    func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> [Key: T] {
        try underlyingDictionary.mapValues(transform)
    }

    func map<T>(_ transform: (Key) throws -> T) rethrows -> [T] {
        try underlyingArray.map(transform)
    }

    func map<T>(_ transform: (Value) throws -> T) rethrows -> [T] {
        try underlyingArray.map { underlyingDictionary[$0]! }
            .map(transform)
    }
}
