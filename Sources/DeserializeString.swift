import Foundation
import SerializableValues

private let controlCharacters: [Character: Character] = [
    "\\": "\\",
    "\"": "\"",
    "/": "/",
    "b": "\u{8}",
    "f": "\u{0C}",
    "n": "\n",
    "r": "\r",
    "t": "\t",
    "u": "u"
]

private enum StringAction {
    case read
    case beginSpecialCharacter
    case beginUTF32HexCharacter
    case endString
}

func deserializeString(characters: String.CharacterView) throws -> (Value, String.CharacterView) {
    var buffer: Buffer = []
    var location = 0
    var action: StringAction = .read
    var unicodeHexBuffer: Buffer = []
    
    outer: for character in characters {
        location += 1
        
        switch(action) {
        case .beginUTF32HexCharacter:
            if unicodeHexBuffer.count == 8 {
                if let number = Int(String(unicodeHexBuffer), radix: 16),
                    let scalar = UnicodeScalar(number) {
                    let char = Character(scalar)
                    buffer.append(char)
                    unicodeHexBuffer.removeAll()
                    action = .read
                } else {
                    throw DeserializationError.malformedControlCharacter
                }
            } else {
                unicodeHexBuffer.append(character)
            }
        case .beginSpecialCharacter:
            if let controlCharacter = controlCharacters[character] {
                if controlCharacter == "u" {
                    action = .beginUTF32HexCharacter
                } else {
                    buffer.append(controlCharacter)
                    action = .read
                }
            } else {
                throw DeserializationError.malformedControlCharacter
            }
        case .read:
            if character == "\"" {
                action = .endString
                break outer
            } else if character == "\\" {
                action = .beginSpecialCharacter
            } else {
                buffer.append(character)
            }
        case .endString:
            throw DeserializationError.parserError
        }
    }
    
    switch(action) {
    case .endString:
        let string = String(buffer)
        let leftOvers = characters.dropFirst(location)
        
        return (.string(string), leftOvers)
    default:
        throw DeserializationError.missingStringTerminator
    }
}
