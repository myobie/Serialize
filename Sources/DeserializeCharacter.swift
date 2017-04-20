import Foundation

enum CharacterAction {
    case beginArray
    case beginObject
    case comma
    case endArray
    case endObject
    case `false`
    case null
    case number(firstCharacter: Character)
    case colon
    case string
    case `true`
    case unknownAtom
    case whitespace
}

internal let whitespaceCharacters: Buffer = [
    " ",
    "\t",
    "\n",
    "\r"
]

private let numbers: Buffer = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

func deserializeCharacter(_ character: Character) -> CharacterAction {
    if character == "[" {
        return .beginArray
    }
    
    if character == "{" {
        return .beginObject
    }
    
    if character == "," {
        return .comma
    }
    
    if character == "]" {
        return .endArray
    }
    
    if character == "}" {
        return .endObject
    }
    
    if character == "f" {
        return .false
    }
    
    if character == "n" {
        return .null
    }
    
    if numbers.contains(character) || character == "-" {
        return .number(firstCharacter: character)
    }
    
    if character == ":" {
        return .colon
    }
    
    if character == "\"" {
        return .string
    }
    
    if character == "t" {
        return .true
    }
    
    if whitespaceCharacters.contains(character) {
        return .whitespace
    }
    
    return .unknownAtom
}
