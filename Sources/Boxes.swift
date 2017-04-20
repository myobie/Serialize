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

class StringBox {
    let string: String
    var view: String.CharacterView
    
    init (_ string: String) {
        self.string = string
        self.view = string.characters
    }
    
    var isEmpty: Bool {
        return view.isEmpty
    }
    
    var count: Int {
        return view.count
    }
    
    var characters: String.CharacterView {
        return view
    }
    
    func prefix(_ num: Int) -> String {
        return String(view.prefix(num))
    }
    
    func removeFirst() -> Character? {
        let char = view.first
        self.view = view.dropFirst()
        return char
    }
    
    func removeFirst(_ num: Int) {
        self.view = view.dropFirst(num)
    }
}
