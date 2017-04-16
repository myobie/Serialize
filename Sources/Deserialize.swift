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
    case missingObjectTerminator
    case missingArrayTerminator
    case missingStringTerminator
    case parserError
    case unknownAtom
}

public func fromJSON(_ string: String) throws -> Value {
    return try deserialize(string)
}

func deserializationComplete(value: Value, remaining: String.CharacterView.SubSequence) throws -> Value {
    if remaining.count == 0 {
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
    
    let firstCharacter = trimmedString.characters.first!
    let characters = trimmedString.characters.dropFirst()
    let initialAction = deserializeCharacter(firstCharacter)
    
    switch(initialAction) {
    case .beginArray:
        let node = Node.root(item: .array(ArrayValue()))
        let (value, leftOvers) = try deserializeNested(into: node, characters: characters)
        return try deserializationComplete(value: value, remaining: leftOvers)
    case .beginObject:
        let node = Node.root(item: .object(DictionaryValue()))
        let (value, leftOvers) = try deserializeNested(into: node, characters: characters)
        return try deserializationComplete(value: value, remaining: leftOvers)
    case .comma:
        throw DeserializationError.malformed
    case .endArray:
        throw DeserializationError.malformed
    case .endObject:
        throw DeserializationError.malformed
    case .false:
        let (value, leftOvers) = try deserializeFalse(characters: characters)
        return try deserializationComplete(value: value, remaining: leftOvers)
    case .number(let negative, let firstCharacter):
        let (value, leftOvers) = try deserializeNumber(negative: negative, firstCharacter: firstCharacter, characters: characters)
        return try deserializationComplete(value: value, remaining: leftOvers)
    case .null:
        let (value, leftOvers) = try deserializeNull(characters: characters)
        return try deserializationComplete(value: value, remaining: leftOvers)
    case .colon:
        throw DeserializationError.malformed
    case .string:
        let (value, leftOvers) = try deserializeString(characters: characters)
        return try deserializationComplete(value: value, remaining: leftOvers)
    case .true:
        let (value, leftOvers) = try deserializeTrue(characters: characters)
        return try deserializationComplete(value: value, remaining: leftOvers)
    case .unknownAtom:
        throw DeserializationError.unknownAtom
    }
}




