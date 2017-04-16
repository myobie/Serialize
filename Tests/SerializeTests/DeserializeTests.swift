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
    
    func testDouble() {
        XCTAssertEqual(Value.double(Double(5.55566677778899)), try deserialize("5.55566677778899"))
    }
    
    func testFloat() {
        XCTAssertEqual(Value.float(1.1), try deserialize("1.1"))
    }
    
    func testNegativeFloat() {
        XCTAssertEqual(Value.float(-1.1), try deserialize("-1.1"))
    }
    
    func testInt() {
        XCTAssertEqual(Value.int(1), try deserialize("1"))
    }
    
    func testLargerInt() {
        XCTAssertEqual(Value.int(987654321), try deserialize("987654321"))
    }
    
    func testScientificNumber() {
        XCTAssertEqual(Value.int(9000000), try deserialize("9e6"))
    }
    
    func testString() {
        XCTAssertEqual(Value.string("hello"), try deserialize("\"hello\""))
    }
    
    func testSimpleArray() {
        let json = "[true]"
        let value = Value([.bool(true)])
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testSimpleObject() {
        let json = "{\"first\": true}"
        let value = Value(["first": .bool(true)])
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testEmptyArray() {
        let json = "[]"
        let value: Value = Value([])
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testEmptyObject() {
        let json = "{}"
        let value: Value = Value([:])
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testMultiItemArray() {
        let json = "[true,\"word\"]"
        let value: Value = Value([ .bool(true), .string("word") ])
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testMultiItemObject() {
        let json = "{\"first\":true,\"second\":false}"
        let value: Value = Value([
            "first": .bool(true),
            "second": .bool(false)
        ])
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
    
    func testNestedObjects() {
        let json = "{\"first\":{\"second\":true}}"
        let value: Value = Value([
            "first": Value([
                "second": .bool(true)
            ])
        ])
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testWhitespace() {
        let json = " [ true ,  \"woo doggy\", false ] "
        let value: Value = Value([
            .bool(true),
            .string("woo doggy"),
            .bool(false)
        ])
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testComplex() {
        let json = "{\"one\": [true, {}, \"false\"], \"two\": {\"fred\":[true]}}"
        let value: Value = Value([
            "one": Value([
                .bool(true),
                Value([:]),
                .string("false")
            ]),
            "two": Value([
                "fred": Value([ .bool(true) ])
            ])
        ])
        XCTAssertEqual(value, try deserialize(json))
    }
}
