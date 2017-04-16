import Foundation
import SerializableValues

typealias ArrayValue = SerializableValues.Array
typealias DictionaryValue = SerializableValues.Dictionary
typealias Location = Int

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

typealias Buffer = [Character]

enum StringAction {
    case read
    case beginSpecialCharacter
    case beginUTF32HexCharacter
    case endString
}

enum FirstCharacterAction {
    case beginArray
    case beginAtom
    case beginObject
    case beginNumber
    case beginString
    case unknownAtom
}

enum Number {
    case int(Int)
    case float(Float)
    case double(Double)
}

enum Atom {
    case `true`
    case `false`
    case null
}

enum Item {
    case array(ArrayValue)
    case atom
    case object(DictionaryValue)
    case number
    case string
    
    func isSameAs(_ item: Item) -> Bool {
        switch(self, item) {
        case (.array, .array):
            return true
        case (.atom, .atom):
            return true
        case (.object, .object):
            return true
        case (.number, .number):
            return true
        case (.string, .string):
            return true
        default:
            return false
        }
    }
}

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
    let characters = trimmedString.characters.dropFirst(1)
    let node: Node = try deserializeFirstCharacter(firstCharacter)
    
    switch(node.item) {
    case .array:
        let (value, leftOvers) = try deserializeNested(into: node, characters: characters)
        return try deserializationComplete(value: value, remaining: leftOvers)
    case .atom:
        let (atom, leftOvers) = try deserializeAtom(initial: firstCharacter, characters: characters)
        let value: Value
        
        switch(atom) {
        case .true:
            value = .bool(true)
        case .false:
            value = .bool(false)
        case .null:
            value = .optional(.int(nil))
        }
        
        return try deserializationComplete(value: value, remaining: leftOvers)
    case .number:
        throw DeserializationError.notImplemented
    case .object:
        let (value, leftOvers) = try deserializeNested(into: node, characters: characters)
        return try deserializationComplete(value: value, remaining: leftOvers)
    case .string:
        let (string, leftOvers) = try deserializeString(characters: characters)
        let value: Value = .string(string)
        return try deserializationComplete(value: value, remaining: leftOvers)
    }
}

let numbers: Buffer = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

let atoms: [String: Atom] = [
    "true": .true,
    "false": .false,
    "null": .null
]
let atomFirstCharacters: Buffer = ["t", "f", "n"]

let controlCharacters: [Character: Character] = [
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

func deserializeFirstCharacter(_ character: Character) throws -> Node {
    let action = parseFirstCharacter(character)
    
    switch(action) {
    case .beginAtom:
        return .root(item: .atom)
    case .beginArray:
        return .root(item: .array(ArrayValue()))
    case .beginNumber:
        return .root(item: .number)
    case .beginObject:
        return .root(item: .object(DictionaryValue()))
    case .beginString:
        return .root(item: .string)
    case .unknownAtom:
        throw DeserializationError.unknownAtom
    }
}

func deserializeFirstCharacter(_ character: Character, into node: Node) throws -> Node {
    let action = parseFirstCharacter(character)
    
    switch(action) {
    case .beginAtom:
        return node.push(.atom)
    case .beginArray:
        return node.push(.array(ArrayValue()))
    case .beginNumber:
        return node.push(.number)
    case .beginObject:
        return node.push(.object(DictionaryValue()))
    case .beginString:
        return node.push(.string)
    case .unknownAtom:
        throw DeserializationError.unknownAtom
    }
}

func parseFirstCharacter(_ character: Character) -> FirstCharacterAction {
    if atomFirstCharacters.contains(character) {
        return .beginAtom
    }
    
    if character == "[" {
        return .beginArray
    }
    
    if character == "{" {
        return .beginObject
    }
    
    if numbers.contains(character) || character == "-" {
        return .beginNumber
    }
    
    if character == "\"" {
        return .beginString
    }
    
    return .unknownAtom
}

enum NestedAction {
    case none
    case complete
}

func deserializeNested(into node: Node, characters: String.CharacterView.SubSequence) throws -> (Value, String.CharacterView.SubSequence) {
    var action: NestedAction = .none
    
    // dun dun dun
    
    switch(action) {
    case .complete:
        throw DeserializationError.notImplemented
    default:
        throw DeserializationError.missingArrayTerminator
    }
}

func deserializeAtom(initial: Character, characters: String.CharacterView.SubSequence) throws -> (Atom, String.CharacterView.SubSequence) {
    var buffer: Buffer = [initial]
    var complete = false
    var location = -1
    var foundAtom: Atom? = nil
    
    for character in characters {
        location += 1
        
        if buffer.count > 5 {
            throw DeserializationError.unknownAtom
        } else {
            buffer.append(character)
            if let atom = atoms[String(buffer)] {
                foundAtom = atom
                complete = true
                break
            }
        }
    }
    
    if complete {
        let atom = foundAtom!
        let leftOvers = characters.dropFirst(location)
        return (atom, leftOvers)
    } else {
        throw DeserializationError.unknownAtom
    }
}

func deserializeString(characters: String.CharacterView.SubSequence) throws -> (String, String.CharacterView.SubSequence) {
    var buffer: Buffer = []
    var location = -1
    var action: StringAction = .read
    var unicodeHexBuffer: Buffer = []
    
    for character in characters {
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
                break
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
        
        return (string, leftOvers)
    default:
        throw DeserializationError.missingStringTerminator
    }
}

