import Foundation
import SerializableValues

enum NestedAction {
    case complete(Value)
    case finishedWithArrayItem
    case finishedWithObjectItem
    case finishedWithObjectItemKey
    case readyForArrayItem
    case readyForObjectItem
    case readyForObjectItemValue
    case none
}

func finishedWithItem(in node: Node) throws -> NestedAction {
    switch (node.item) {
    case .array(_):
        return .finishedWithArrayItem
    case .object(_):
        return .finishedWithObjectItem
    case .pendingObject(_, _):
        throw DeserializationError.parserError
    }
}

func processCompleteItem(node: Node, value: Value) throws -> (Node, NestedAction) {
    let newNode = try node.appending(value)
    let action = try finishedWithItem(in: newNode)
    
    return (newNode, action)
}

func processEnding(node: Node, value: Value) throws -> (Node, NestedAction) {
    if let parent = node.parent {
        return try processCompleteItem(node: parent, value: value)
    } else {
        return (node, .complete(value))
    }
}

func deserializeNested(into node: Node, characters: String.CharacterView) throws -> (Value, String.CharacterView) {
    if characters.count == 0 {
        switch(node.item) {
        case .array(_):
            throw DeserializationError.missingArrayTerminator
        case .object(_):
            throw DeserializationError.missingObjectTerminator
        case .pendingObject(_, _):
            throw DeserializationError.parserError
        }
    }
    
    var action: NestedAction
    var node = node
    var characters = characters
    
    switch (node.item) {
    case .array(_):
        action = .readyForArrayItem
    case .object(_):
        action = .readyForObjectItem
    case .pendingObject(_, _):
        throw DeserializationError.parserError
    }
    
    outer: while true {
        if case .complete(_) = action {
            break
        }
        
        if let character = characters.first {
            characters = characters.dropFirst()
            let characterAction = deserializeCharacter(character)
            
            switch (characterAction) {
            case .beginArray:
                node = node.push(.array(ArrayValue()))
                action = .readyForArrayItem
            case .beginObject:
                node = node.push(.object(DictionaryValue()))
                action = .readyForObjectItem
            case .colon:
                switch (node.item, action) {
                case (.pendingObject(_, _), .finishedWithObjectItemKey):
                    action = .readyForObjectItemValue
                default:
                    throw DeserializationError.malformed
                }
            case .comma:
                switch (action) {
                case .finishedWithArrayItem:
                    action = .readyForArrayItem
                case .finishedWithObjectItem:
                    action = .readyForObjectItem
                default:
                    throw DeserializationError.malformed
                }
            case .endArray:
                switch (node.item) {
                case .array(let arr):
                    let alright: Bool
                    
                    switch (action) {
                    case .readyForArrayItem:
                        alright = arr.isEmpty
                    case .finishedWithArrayItem:
                        alright = true
                    default:
                        alright = false
                    }
                    
                    guard alright else {
                        throw DeserializationError.malformed
                    }
                    
                    let (newNode, newAction) = try processEnding(node: node, value: try node.value())
                    
                    node = newNode
                    action = newAction
                case .object(_):
                    throw DeserializationError.malformed
                case .pendingObject(_, _):
                    throw DeserializationError.malformed
                }
            case .endObject:
                switch (node.item) {
                case .array(_):
                    throw DeserializationError.malformed
                case .object(let dict):
                    let alright: Bool
                    
                    switch (action) {
                    case .readyForObjectItem:
                        // the only way we'd be ready for a new item is if we just started
                        alright = dict.isEmpty
                    case .finishedWithObjectItem:
                        alright = true
                    default:
                        alright = false
                    }
                    
                    guard alright else {
                        throw DeserializationError.malformed
                    }
                    
                    let (newNode, newAction) = try processEnding(node: node, value: try node.value())
                    
                    node = newNode
                    action = newAction
                case .pendingObject(_, _):
                    throw DeserializationError.malformed
                }
            case .false:
                switch (action) {
                case .readyForArrayItem, .readyForObjectItemValue:
                    let (value, newCharacters) = try deserializeFalse(characters: characters)
                    let (newNode, newAction) = try processCompleteItem(node: node, value: value)
                    
                    node = newNode
                    action = newAction
                    characters = newCharacters
                default:
                    throw DeserializationError.malformed
                }
            case .null:
                switch (action) {
                case .readyForArrayItem, .readyForObjectItemValue:
                    let (value, newCharacters) = try deserializeNull(characters: characters)
                    let (newNode, newAction) = try processCompleteItem(node: node, value: value)
                    
                    node = newNode
                    action = newAction
                    characters = newCharacters
                default:
                    throw DeserializationError.malformed
                }
            case .number(let negative, let firstCharacter):
                switch (action) {
                case .readyForArrayItem, .readyForObjectItemValue:
                    let (value, newCharacters) = try deserializeNumber(negative: negative, firstCharacter: firstCharacter, characters: characters)
                    let (newNode, newAction) = try processCompleteItem(node: node, value: value)
                    
                    node = newNode
                    action = newAction
                    characters = newCharacters
                default:
                    throw DeserializationError.malformed
                }
            case .string:
                switch (action) {
                case .readyForArrayItem, .readyForObjectItemValue:
                    let (value, newCharacters) = try deserializeString(characters: characters)
                    let (newNode, newAction) = try processCompleteItem(node: node, value: value)
                    
                    node = newNode
                    action = newAction
                    characters = newCharacters
                case .readyForObjectItem:
                    let (value, newCharacters) = try deserializeString(characters: characters)
                    
                    if let string = value.stringValue {
                        node = try node.addKey(string)
                        action = .finishedWithObjectItemKey
                        characters = newCharacters
                    } else {
                        throw DeserializationError.parserError
                    }
                    
                default:
                    throw DeserializationError.malformed
                }
            case .true:
                switch (action) {
                case .readyForArrayItem, .readyForObjectItemValue:
                    let (value, newCharacters) = try deserializeTrue(characters: characters)
                    let (newNode, newAction) = try processCompleteItem(node: node, value: value)
                    
                    node = newNode
                    action = newAction
                    characters = newCharacters
                default:
                    throw DeserializationError.malformed
                }
            case .unknownAtom:
                throw DeserializationError.unknownAtom
            }
        } else {
            break outer
        }
    }
    
    switch(action) {
    case .complete(let value):
        return (value, characters)
    default:
        switch(node.item) {
        case .array(_):
            throw DeserializationError.missingArrayTerminator
        case .object(_):
            throw DeserializationError.missingObjectTerminator
        case .pendingObject(_, _):
            throw DeserializationError.malformed
        }
    }
}

