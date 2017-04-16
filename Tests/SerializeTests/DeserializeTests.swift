import XCTest
@testable import Serialize
import SerializableValues

class DeserializeTests: XCTestCase {
    func testBool() {
        XCTAssertEqual(Value.bool(true), try deserialize("true"))
        XCTAssertEqual(Value.bool(false), try deserialize("false"))
    }
    
    func testNull() {
        XCTAssertEqual(Value.optional(.int(nil)), try deserialize("null"))
    }
    
//    func testDoubleAtom() {
//        XCTAssertEqual(Value.double(Double(5.555666777)), try deserialize("5.555666777"))
//    }
//    
//    func testFloatAtom() {
//        XCTAssertEqual(Value.float(1.1), try deserialize("1.1"))
//    }
//    
//    func testIntAtom() {
//        XCTAssertEqual(Value.int(1), try deserialize("1"))
//    }
    
    func testString() {
        XCTAssertEqual(Value.string("hello"), try deserialize("\"hello\""))
    }
    
    func testSimpleArray() {
        XCTAssertEqual(Value.array(ArrayValue([Value.bool(true)])), try deserialize("[true]"))
    }
    
    func testMultiItemArray() {
        let json = "[true,\"word\"]"
        let value: Value = Value([ .bool(true), .string("word") ])
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testNestedArrays() {
        let json = "[true,[\"blah\",false],false]"
        let value: Value = Value([
            .bool(true),
            Value([.string("blah"), .bool(false)]),
            .bool(false)
        ])
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testWhitespace() {
        let json = "[ true , \"woo doggy\", false ]"
        let value: Value = Value([ .bool(true), .string("woo doggy"), .bool(false) ])
        XCTAssertEqual(value, try deserialize(json))
    }
}
