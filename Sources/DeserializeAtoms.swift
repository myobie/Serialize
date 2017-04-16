import Foundation
import SerializableValues

func deserializeFalse(characters: String.CharacterView) throws -> (Value, String.CharacterView) {
    let four = String(characters.prefix(4))

    if four == "alse" {
        let leftOvers = characters.dropFirst(4)
        return (.bool(false), leftOvers)
    } else {
        throw DeserializationError.unknownAtom
    }
}

func deserializeNull(characters: String.CharacterView) throws -> (Value, String.CharacterView) {
    let three = String(characters.prefix(3))
    
    if three == "ull" {
        let leftOvers = characters.dropFirst(3)
        return (.optional(.int(nil)), leftOvers)
    } else {
        throw DeserializationError.unknownAtom
    }
}

func deserializeTrue(characters: String.CharacterView) throws -> (Value, String.CharacterView) {
    let three = String(characters.prefix(3))
    
    if three == "rue" {
        let leftOvers = characters.dropFirst(3)
        return (.bool(true), leftOvers)
    } else {
        throw DeserializationError.unknownAtom
    }
}
