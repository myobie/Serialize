import Foundation
import SerializableValues

func deserializeFalse(box: StringBox) throws -> Value {
    let four = box.prefix(4)

    if four == "alse" {
        box.removeFirst(4)
        return .bool(false)
    } else {
        throw DeserializationError.unknownAtom
    }
}

func deserializeNull(box: StringBox) throws -> Value {
    let three = box.prefix(3)
    
    if three == "ull" {
        box.removeFirst(3)
        return .optional(.int(nil))
    } else {
        throw DeserializationError.unknownAtom
    }
}

func deserializeTrue(box: StringBox) throws -> Value {
    let three = box.prefix(3)
    
    if three == "rue" {
        box.removeFirst(3)
        return .bool(true)
    } else {
        throw DeserializationError.unknownAtom
    }
}
