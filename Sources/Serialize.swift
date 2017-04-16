import Foundation
import SerializableValues

public func toJSON(_ value: Value) -> String {
    return serialize(value)
}

func serialize(_ value: Value?) -> String {
    if let value = value {
        return serialize(value)
    } else {
        return "null"
    }
}

func serialize(_ value: Value) -> String {
    switch value {
    case .array(let value):
        return serialize(value)
    case .bool(let value):
        return serialize(value)
    case .custom(let value):
        return serialize(value.serializableValue)
    case .date(_):
        return serialize(value.stringValue)
    case .dictionary(let value):
        return serialize(value)
    case .double(let value):
        return serialize(value)
    case .float(let value):
        return serialize(value)
    case .int(let value):
        return serialize(value)
    case .optional(let value):
        return serialize(value.serializableValue)
    case .string(let value):
        return serialize(value)
    case .url(_):
        return serialize(value.stringValue)
    }
}

func serialize(_ value: SerializableValues.Dictionary?) -> String {
    if let value = value {
        return serialize(value)
    } else {
        return "null"
    }
}

func serialize(_ value: SerializableValues.Dictionary) -> String {
    return "{\(value.map { "\(serialize($0)):\(serialize($1))" }.joined(separator: ","))}"
}

func serialize(_ value: SerializableValues.Array?) -> String {
    if let value = value {
        return serialize(value)
    } else {
        return "null"
    }
}

func serialize(_ value: SerializableValues.Array) -> String {
    return "[\(value.map { serialize($0) }.joined(separator: ","))]"
}

func serialize(_ value: Bool?) -> String {
    if let value = value {
        return serialize(value)
    } else {
        return "null"
    }
}

func serialize(_ value: Bool) -> String {
    if value {
        return "true"
    } else {
        return "false"
    }
}

func serialize(_ value: Double?) -> String {
    if let value = value {
        return serialize(value)
    } else {
        return "null"
    }
}

func serialize(_ value: Double) -> String {
    return String(value)
}

func serialize(_ value: Float?) -> String {
    if let value = value {
        return serialize(value)
    } else {
        return "null"
    }
}

func serialize(_ value: Float) -> String {
    return String(value)
}

func serialize(_ value: Int?) -> String {
    if let value = value {
        return serialize(value)
    } else {
        return "null"
    }
}

func serialize(_ value: Int) -> String {
    return String(value)
}

func serialize(_ value: String?) -> String {
    if let value = value {
        return serialize(value)
    } else {
        return "null"
    }
}

func serialize(_ value: String) -> String {
    return "\"\(value.replacingOccurrences(of: "\"", with: "\\\""))\""
}

