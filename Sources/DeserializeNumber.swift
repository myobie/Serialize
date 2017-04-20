import Foundation
import SerializableValues

private enum NumberAction {
    case read
    case afterDecimal
    case afterScientific
}

private let numbers: Buffer = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

private let endings: Buffer = [",", "]", "}"] + whitespaceCharacters

private func parseInt(_ buffer: Buffer) throws -> Int {
    if let int = Int(String(buffer)) {
        return int
    } else {
        throw DeserializationError.parserError
    }
}

private func parseDouble(_ intBuffer: Buffer, _ decimalBuffer: Buffer) throws -> Double {
    if let double = Double("\(String(intBuffer)).\(String(decimalBuffer))") {
        return double
    } else {
        throw DeserializationError.parserError
    }
}

func deserializeNumber(firstCharacter: Character, box: StringBox) throws -> Value {
    let negative: Bool
    var intBuffer: Buffer = []
    var decimalBuffer: Buffer = []
    var negativeExponent = false
    var exponentBuffer: Buffer = []
    var location = 0
    var action: NumberAction = .read
    
    negative = firstCharacter == "-"
    
    if box.isEmpty {
        if negative {
            throw DeserializationError.malformedNumber
        } else {
            if let int = Int(String(firstCharacter)) {
                return .int(int)
            } else {
                throw DeserializationError.parserError
            }
        }
    }
    
    if !negative && numbers.contains(firstCharacter) {
        intBuffer.append(firstCharacter)
    }
    
    outer: for character in box.characters {
        location += 1
        
        if numbers.contains(character) {
            switch (action) {
            case .read:
                intBuffer.append(character)
            case .afterDecimal:
                decimalBuffer.append(character)
            case .afterScientific:
                exponentBuffer.append(character)
            }
        } else if character == "." {
            switch (action) {
            case .read:
                action = .afterDecimal
            case .afterDecimal, .afterScientific:
                throw DeserializationError.malformedNumber
            }
        } else if character == "e" {
            switch (action) {
            case .read, .afterDecimal:
                action = .afterScientific
            case .afterScientific:
                throw DeserializationError.malformedNumber
            }
        } else if character == "-" {
            switch (action) {
            case .read, .afterDecimal:
                throw DeserializationError.malformedNumber
            case .afterScientific:
                if exponentBuffer.isEmpty {
                    negativeExponent = true
                } else {
                    throw DeserializationError.malformedNumber
                }
            }
        } else if endings.contains(character) {
            location -= 1 // we don't want to remove the comma or what have you
            break outer
        } else {
            throw DeserializationError.malformedNumber
        }
    }
    
    box.removeFirst(location)
    
    let exp: Int? = nil
    
//    if !exponentBuffer.isEmpty {
//        var int = try parseInt(exponentBuffer)
//        if negativeExponent {
//            int *= -1
//        }
//        exp = pow(10, int)
//    } else {
//        exp = nil
//    }
    
    if decimalBuffer.isEmpty {
        var int = try parseInt(intBuffer)
        
        if let exp = exp {
            int = int * exp
        }
        
        if negative {
            int *= -1
        }
        
        return .int(int)
    } else {
        var double = try parseDouble(intBuffer, decimalBuffer)
        
        if let exp = exp {
            double = double * Double(exp)
        }
        
        if negative {
            double *= Double(-1)
        }
        
        return .double(double)
    }
}
