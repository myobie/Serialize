import Foundation
import SerializableValues

enum Number {
    case int(Int)
    case float(Float)
    case double(Double)
}

let numbers: Buffer = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

func deserializeNumber(negative: Bool, firstCharacter: Character?, characters: String.CharacterView) throws -> (Value, String.CharacterView) {
    throw DeserializationError.notImplemented
}
