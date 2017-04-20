import Foundation

class ArrayBox {
    var array: ArrayValue
    
    init() {
        self.array = ArrayValue()
    }
    
    var isEmpty: Bool {
        return array.isEmpty
    }
}

class DictionaryBox {
    var dictionary: DictionaryValue
    
    init() {
        self.dictionary = DictionaryValue()
    }
    
    var isEmpty: Bool {
        return dictionary.isEmpty
    }
}

class KeyBox {
    var key: String?
    
    init() {
        self.key = nil
    }
    
    var isEmpty: Bool {
        return key == nil
    }
}
