import Foundation

enum CharacterAction {
    case beginArray
    case beginObject
    case comma
    case endArray
    case endObject
    case `false`
    case null
    case number(negative: Bool, firstCharacter: Character?)
    case colon
    case string
    case `true`
    case unknownAtom
}

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
    
    if numbers.contains(character) {
        return .number(negative: false, firstCharacter: character)
    }
    
    if character == "-" {
        return .number(negative: true, firstCharacter: nil)
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
    
    return .unknownAtom
}
