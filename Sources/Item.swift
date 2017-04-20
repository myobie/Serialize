import Foundation
import SerializableValues

enum Item {
    case array(ArrayBox)
    case object(DictionaryBox, KeyBox)
    
    static func newArray() -> Item {
        return Item.array(ArrayBox())
    }
    
    static func newObject() -> Item {
        return Item.object(DictionaryBox(), KeyBox())
    }
    
    func value() throws -> Value {
        switch (self) {
        case .array(let arrayBox):
            return .array(arrayBox.array)
        case .object(let dictionaryBox, let keyBox):
            if keyBox.isEmpty {
                return .dictionary(dictionaryBox.dictionary)
            } else {
                throw DeserializationError.parserError
            }
        }
    }
    
    func setKey(_ key: String) throws {
        switch (self) {
        case .array(_):
            throw DeserializationError.parserError
        case .object(_, let keyBox):
            if keyBox.key == nil {
                keyBox.key = key
            } else {
                throw DeserializationError.parserError
            }
        }
    }
    
    func append(_ value: Value) throws {
        switch (self) {
        case .array(let arrayBox):
            arrayBox.array.rawArray.append(value)
        case .object(let dictionaryBox, let keyBox):
            if let key = keyBox.key {
                dictionaryBox.dictionary.rawDictionary[key] = value
                keyBox.key = nil
            } else {
                throw DeserializationError.parserError
            }
        }
    }
}
