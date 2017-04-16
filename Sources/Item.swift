import Foundation
import SerializableValues

enum Item {
    case array(ArrayValue)
    case object(DictionaryValue)
    case pendingObject(DictionaryValue, String)
    
    func value() throws -> Value {
        switch (self) {
        case .array(let value):
            return .array(value)
        case .object(let value):
            return .dictionary(value)
        case .pendingObject(_, _):
            throw DeserializationError.parserError
        }
    }
    
    func addKey(_ key: String) throws -> Item {
        switch (self) {
        case .array(_):
            throw DeserializationError.parserError
        case .object(let dict):
            return Item.pendingObject(dict, key)
        case .pendingObject(_, _):
            throw DeserializationError.parserError
        }
    }
    
    func appending(_ value: Value) throws -> Item {
        switch (self) {
        case .array(let arr):
            var rawArray = arr.rawArray
            rawArray.append(value)
            
            let newItem = Item.array(ArrayValue(rawArray))
            return newItem
        case .object(_):
            throw DeserializationError.parserError
        case .pendingObject(let dict, let key):
            var rawDictionary = dict.rawDictionary
            rawDictionary[key] = value
            
            let newItem = Item.object(DictionaryValue(rawDictionary))
            return newItem
        }
    }
}
