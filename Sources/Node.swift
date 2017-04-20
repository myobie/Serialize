import Foundation
import SerializableValues

indirect enum Node {
    case root(item: Item)
    case child(item: Item, parent: Node, depth: Int)
    
    var item: Item {
        switch(self) {
        case .root(let item):
            return item
        case .child(let item, _, _):
            return item
        }
    }
    
    func value() throws -> Value {
        return try self.item.value()
    }
    
    func push(_ item: Item) -> Node {
        switch(self) {
        case .root(_):
            return .child(item: item, parent: self, depth: 1)
        case .child(_, _, let depth):
            return .child(item: item, parent: self, depth: depth + 1)
        }
    }
    
    func pushArray() -> Node {
        return push(Item.newArray())
    }
    
    func pushObject() -> Node {
        return push(Item.newObject())
    }
    
    var parent: Node? {
        switch(self) {
        case .root(_):
            return nil
        case .child(_, let parent, _):
            return parent
        }
    }
    
    func append(_ value: Value) throws {
        try item.append(value)
    }
    
    func setKey(_ key: String) throws {
        try item.setKey(key)
    }
}
