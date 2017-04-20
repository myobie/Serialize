import Foundation
import SerializableValues

typealias ArrayValue = SerializableValues.Array
typealias DictionaryValue = SerializableValues.Dictionary
typealias Location = Int
typealias Buffer = [Character]

enum DeserializationError: Error {
    case notImplemented
    case empty
    case malformed
    case malformedControlCharacter
    case malformedNumber
    case missingObjectTerminator
    case missingArrayTerminator
    case missingStringTerminator
    case parserError
    case unknownAtom
}

public func fromJSON(_ string: String) throws -> Value {
    return try deserialize(string)
}

private func deserializationComplete(value: Value, box: StringBox) throws -> Value {
    var nextCharacter: Character
    
    repeat {
        if let char = box.removeFirst() {
            nextCharacter = char
        } else {
            nextCharacter = "A"
        }
    } while whitespaceCharacters.contains(nextCharacter)
    
    if box.isEmpty {
        return value
    } else {
        throw DeserializationError.malformed
    }
}

func deserialize(_ string: String) throws -> Value {
    let trimmedString = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    
    if trimmedString.characters.count == 0 {
        throw DeserializationError.empty
    }
    
    let box = StringBox(string)
    var firstCharacter: Character
    
    repeat {
        if let char = box.removeFirst() {
            firstCharacter = char
        } else {
            throw DeserializationError.empty
        }
    } while whitespaceCharacters.contains(firstCharacter)
    
    let initialAction = deserializeCharacter(firstCharacter)
    
    switch(initialAction) {
    case .beginArray:
        let node = Node.root(item: Item.newArray())
        let value = try deserializeNested(into: node, box: box)
        return try deserializationComplete(value: value, box: box)
    case .beginObject:
        let node = Node.root(item: Item.newObject())
        let value = try deserializeNested(into: node, box: box)
        return try deserializationComplete(value: value, box: box)
    case .comma:
        throw DeserializationError.malformed
    case .endArray:
        throw DeserializationError.malformed
    case .endObject:
        throw DeserializationError.malformed
    case .false:
        let value = try deserializeFalse(box: box)
        return try deserializationComplete(value: value, box: box)
    case .number(let firstCharacter):
        let value = try deserializeNumber(firstCharacter: firstCharacter, box: box)
        return try deserializationComplete(value: value, box: box)
    case .null:
        let value = try deserializeNull(box: box)
        return try deserializationComplete(value: value, box: box)
    case .colon:
        throw DeserializationError.malformed
    case .string:
        let value = try deserializeString(box: box)
        return try deserializationComplete(value: value, box: box)
    case .true:
        let value = try deserializeTrue(box: box)
        return try deserializationComplete(value: value, box: box)
    case .unknownAtom:
        throw DeserializationError.unknownAtom
    case .whitespace:
        throw DeserializationError.parserError
    }
}




