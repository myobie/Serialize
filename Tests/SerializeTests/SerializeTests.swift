import XCTest
@testable import Serialize
import SerializableValues

class SerializeTests: XCTestCase {
    func testBoolAtom() {
        XCTAssertEqual("true", serialize(true))
        XCTAssertEqual("false", serialize(false))
    }
    
    func testDoubleAtom() {
        XCTAssertEqual("5.555666777", serialize(Double(5.555666777)))
    }
    
    func testFloatAtom() {
        XCTAssertEqual("1.1", serialize(1.1))
    }
    
    func testIntAtom() {
        XCTAssertEqual("1", serialize(1))
    }
    
    func testStringAtom() {
        XCTAssertEqual("\"hello\"", serialize("hello"))
    }
    
    func testSimpleArray() {
        let simple = Value([
                "one",
                2,
                3.1,
                true
            ])
        
        XCTAssertEqual("[\"one\",2,3.1,true]", serialize(simple))
    }
    
    func testSimpleObject() {
        let simple: Value  = [
            "hello": "world",
            "one": 1
        ]
        
        XCTAssertEqual("{\"hello\":\"world\",\"one\":1}", serialize(simple))
    }
    
    func testOptionalStuff() {
        let arr: Value = [.optional(.string(nil))]
        
        XCTAssertEqual("[null]", serialize(arr))
    }
    
    func testNestedStructures() {
        let nested = Value([
                "one": [
                    "two":[
                        true,
                        [1,2,3]
                    ],
                    "three":[
                        "four": 4
                    ]
                ]
            ])!
        
        XCTAssertEqual("{\"one\":{\"three\":{\"four\":4},\"two\":[true,[1,2,3]]}}", serialize(nested))
    }
}
