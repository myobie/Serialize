import Foundation
import SerializableValues

private enum NestedAction {
    case complete(Value)
    case finishedWithArrayItem
    case finishedWithObjectItem
    case finishedWithObjectItemKey
    case readyForArrayItem
    case readyForObjectItem
    case readyForObjectItemValue
    case none
}

private func finishedWithItem(in node: Node) throws -> NestedAction {
    switch (node.item) {
    case .array(_):
        return .finishedWithArrayItem
    case .object(_, let keyBox):
        if keyBox.isEmpty {
            return .finishedWithObjectItem
        } else {
            throw DeserializationError.parserError
        }
    }
}

private func processCompleteItem(node: Node, value: Value) throws -> NestedAction {
    try node.append(value)
    let action = try finishedWithItem(in: node)
    
    return action
}

private func processEnding(node: Node, value: Value) throws -> (Node, NestedAction) {
    if let parent = node.parent {
        let action = try processCompleteItem(node: parent, value: value)
        return (parent, action)
    } else {
        return (node, .complete(value))
    }
}

func deserializeNested(into node: Node, box: StringBox) throws -> Value {
    if box.isEmpty {
        switch(node.item) {
        case .array(_):
            throw DeserializationError.missingArrayTerminator
        case .object(_, let keyBox):
            if keyBox.isEmpty {
                throw DeserializationError.missingObjectTerminator
            } else {
                throw DeserializationError.parserError
            }
        }
    }
    
    var node = node
    
    var action: NestedAction
    
    switch (node.item) {
    case .array(_):
        action = .readyForArrayItem
    case .object(_, let keyBox):
        if keyBox.isEmpty {
            action = .readyForObjectItem
        } else {
            throw DeserializationError.parserError
        }
    }
    
    outer: while true {
        if case .complete(_) = action {
            break outer
        }
        
        if let character = box.removeFirst() {
            let characterAction = deserializeCharacter(character)
            
            switch (characterAction) {
            case .beginArray:
                node = node.pushArray()
                action = .readyForArrayItem
            case .beginObject:
                node = node.pushObject()
                action = .readyForObjectItem
            case .colon:
                switch (node.item, action) {
                case (.object(_, let keyBox), .finishedWithObjectItemKey):
                    if keyBox.key == nil {
                        throw DeserializationError.malformed
                    } else {
                        action = .readyForObjectItemValue
                    }
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
                case .array(let arrayBox):
                    let alright: Bool
                    
                    switch (action) {
                    case .readyForArrayItem:
                        alright = arrayBox.isEmpty
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
                case .object(_, _):
                    throw DeserializationError.malformed
                }
            case .endObject:
                switch (node.item) {
                case .array(_):
                    throw DeserializationError.malformed
                case .object(let dictionaryBox, let keyBox):
                    guard keyBox.isEmpty else {
                        throw DeserializationError.malformed
                    }
                    
                    let alright: Bool
                    
                    switch (action) {
                    case .readyForObjectItem:
                        // the only way we'd be ready for a new item is if we just started
                        alright = dictionaryBox.isEmpty
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
                }
            case .false:
                switch (action) {
                case .readyForArrayItem, .readyForObjectItemValue:
                    let value = try deserializeFalse(box: box)
                    action = try processCompleteItem(node: node, value: value)
                default:
                    throw DeserializationError.malformed
                }
            case .null:
                switch (action) {
                case .readyForArrayItem, .readyForObjectItemValue:
                    let value = try deserializeNull(box: box)
                    action = try processCompleteItem(node: node, value: value)
                default:
                    throw DeserializationError.malformed
                }
            case .number(let firstCharacter):
                switch (action) {
                case .readyForArrayItem, .readyForObjectItemValue:
                    let value = try deserializeNumber(firstCharacter: firstCharacter, box: box)
                    action = try processCompleteItem(node: node, value: value)
                default:
                    throw DeserializationError.malformed
                }
            case .string:
                switch (action) {
                case .readyForArrayItem, .readyForObjectItemValue:
                    let value = try deserializeString(box: box)
                    action = try processCompleteItem(node: node, value: value)
                case .readyForObjectItem:
                    let value = try deserializeString(box: box)
                    
                    if let string = value.stringValue {
                        try node.setKey(string)
                        action = .finishedWithObjectItemKey
                    } else {
                        throw DeserializationError.parserError
                    }
                    
                default:
                    throw DeserializationError.malformed
                }
            case .true:
                switch (action) {
                case .readyForArrayItem, .readyForObjectItemValue:
                    let value = try deserializeTrue(box: box)
                    action = try processCompleteItem(node: node, value: value)
                default:
                    throw DeserializationError.malformed
                }
            case .unknownAtom:
                throw DeserializationError.unknownAtom
            case .whitespace:
                continue outer
            }
        } else {
            break outer
        }
    }
    
    switch(action) {
    case .complete(let value):
        return value
    default:
        switch(node.item) {
        case .array(_):
            throw DeserializationError.missingArrayTerminator
        case .object(_, _):
            throw DeserializationError.missingObjectTerminator
        }
    }
}

