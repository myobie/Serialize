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
    
    private func replace(_ item: Item) -> Node {
        switch (self) {
        case .root(_):
            return .root(item: item)
        case .child(_, let parent, let depth):
            return .child(item: item, parent: parent, depth: depth)
        }
    }
    
    func push(_ item: Item) -> Node {
        switch(self) {
        case .root(_):
            return .child(item: item, parent: self, depth: 1)
        case .child(_, _, let depth):
            return .child(item: item, parent: self, depth: depth + 1)
        }
    }
    
    var parent: Node? {
        switch(self) {
        case .root(_):
            return nil
        case .child(_, let parent, _):
            return parent
        }
    }
    
    func appending(_ value: Value) throws -> Node {
        let newItem = try item.appending(value)
        return replace(newItem)
    }
    
    func addKey(_ key: String) throws -> Node {
        let newItem = try item.addKey(key)
        return replace(newItem)
    }
}
