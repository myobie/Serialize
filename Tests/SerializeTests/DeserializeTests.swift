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
        XCTAssertEqual(Value.double(1.1), try deserialize("1.1"))
    }
    
    func testNegativeFloat() {
        XCTAssertEqual(Value.double(-1.1), try deserialize("-1.1"))
    }
    
    func testInt() {
        XCTAssertEqual(Value.int(1), try deserialize("1"))
    }
    
    func testLargerInt() {
        XCTAssertEqual(Value.int(987654321), try deserialize("987654321"))
    }
    
//    func testScientificNumber() {
//        XCTAssertEqual(Value.int(9000000), try deserialize("9e6"))
//    }
    
    func testString() {
        XCTAssertEqual(Value.string("hello"), try deserialize("\"hello\""))
    }
    
    func testSimpleArray() {
        let json = "[true]"
        let value: Value = [true]
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testSimpleObject() {
        let json = "{\"first\": true}"
        let value: Value = ["first": true]
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testEmptyArray() {
        let json = "[]"
        let value: Value = []
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testEmptyObject() {
        let json = "{}"
        let value: Value = [:]
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testMultiItemArray() {
        let json = "[true,\"word\"]"
        let value: Value = [true, "word"]
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testMultiItemObject() {
        let json = "{\"first\":true,\"second\":false}"
        let value: Value = [
            "first": true,
            "second": false
        ]
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testNestedArrays() {
        let json = "[true,[\"blah\",false],false]"
        let value: Value = [true, ["blah", false], false]
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testNestedObjects() {
        let json = "{\"first\":{\"second\":true}}"
        let value: Value = ["first": ["second": true]]
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testWhitespace() {
        let json = " [ true ,  \"woo doggy\", 2 ] "
        let value: Value = [true, "woo doggy", 2]
        XCTAssertEqual(value, try deserialize(json))
    }
    
    func testComplex() {
        let json = "{\"one\": [true, {}, \"false\"], \"two\": {\"fred\":[2]}}"
        let value: Value = [
            "one": [true, [:], "false"],
            "two": ["fred": [2]]
        ]
        XCTAssertEqual(value, try deserialize(json))
    }
    
    let performanceJSON = "{\"other\":1,\"one\":{\"two\":{\"three\":{\"other\":4,\"four\":{\"other\":5,\"five\":{\"six\":{\"seven\":{\"other\":1234567890,\"eight\":{\"other\":null,\"nine\":{\"ten\":[1,2,3,4,\"five\",6,true,8,9,10.1]}}},\"other\":7},\"other\":6}}},\"other\":[1,2,3]},\"other\":2}}"
    lazy var performanceData: Data = {
        self.performanceJSON.data(using: .utf8)!
    }()
    
    let expectedPerformanceValue: Value = [
        "other": 1,
        "one": [
            "two": [
                "three": [
                    "other": 4,
                    "four": [
                        "other": 5,
                        "five": [
                            "six": [
                                "seven": [
                                    "other": 1234567890,
                                    "eight": [
                                        "other": .optional(.int(nil)),
                                        "nine": [
                                            "ten": [1, 2, 3, 4, "five", 6, true, 8, 9, 10.1]
                                        ]
                                    ]
                                    
                                ],
                                "other": 7
                            ],
                            "other": 6
                        ]
                    ]
                    
                ],
                "other": [1, 2, 3]
            ],
            "other": 2
        ]
        
    ]
    
    func checkNested(key: String, value: Value, other: DictionaryValue) {
        XCTAssertNotNil(other[key])
        
        if let dict = value.dictionaryValue {
            if let otherDict = other[key]?.dictionaryValue {
                for (k, v) in dict {
                    checkNested(key: k, value: v, other: otherDict)
                }
            } else {
                XCTAssertEqual(value, other[key]!)
            }
        } else {
            XCTAssertEqual(value, other[key]!)
        }
    }
    
    func testCanDeserializePerformanceJSON() {
        let value = try! deserialize(performanceJSON)
        
        XCTAssertNotNil(value)
        XCTAssertNotNil(value.dictionaryValue)
        
        for (key, value) in value.dictionaryValue! {
            checkNested(key: key, value: value, other: expectedPerformanceValue.dictionaryValue!)
        }
        
        XCTAssertEqual(expectedPerformanceValue, value)
    }
    
    // Only works on 64bit
    let trueNumber = NSNumber(booleanLiteral: true)
    let falseNumber = NSNumber(booleanLiteral: false)
    
    func valuefromJSONSerialization(_ any: Any) -> Value? {
        if let any = any as? NSNumber {
            if any === falseNumber {
                return .bool(false)
            } else if any === trueNumber {
                return .bool(true)
            } else {
                if Double(any.intValue) == any.doubleValue {
                    return .int(any.intValue)
                } else {
                    return .double(any.doubleValue)
                }
            }
        } else if let any = any as? [Any] {
            var values: [Value] = []
            
            for item in any {
                if let value = valuefromJSONSerialization(item) {
                    values.append(value)
                } else {
                    return nil
                }
            }
            
            return .array(ArrayValue(values))
        } else if let any = any as? [String: Any] {
            var dictionary: [String: Value] = [:]
            
            for (key, item) in any {
                if let value = valuefromJSONSerialization(item) {
                    dictionary[key] = value
                } else {
                    return nil
                }
            }
            
            return .dictionary(DictionaryValue(dictionary))
        } else if let int = any as? Int { // Int is less greedy, so it comes before Double and Float
            return .int(int)
        } else if let double = any as? Double {
            return .double(double)
        } else if let float = any as? Float {
            return .float(float)
        } else if let string = any as? String {
            return .string(string)
        } else if let bool = any as? Bool { // lots of things convert to bools, so this should come last
            return .bool(bool)
        } else if NSNull().isEqual(any) {
            return .optional(.int(nil))
        } else {
            return nil // all unknown types fail to initialize
        }
    }
    
    func testCanDeserializePerformanceJSONWithJSONSerialization() {
        let value = valuefromJSONSerialization(try! JSONSerialization.jsonObject(with: self.performanceData, options: []))
        
        XCTAssertNotNil(value)
        XCTAssertNotNil(value!.dictionaryValue)
        
        for (key, value) in value!.dictionaryValue! {
            checkNested(key: key, value: value, other: expectedPerformanceValue.dictionaryValue!)
        }
        
        XCTAssertEqual(expectedPerformanceValue, value)
    }
    
    func testPerformanceOfSerialize() {
        var results: [Value] = []
        
        measure() {
            for _ in 1...10000 {
                results.append(try! deserialize(self.performanceJSON))
            }
        }
        
        print(results.count)
    }
    
    func testPerformanceOfJSONSerialization() {
        var results: [Value] = []
        
        measure() {
            for _ in 1...10000 {
                let any = try! JSONSerialization.jsonObject(with: self.performanceData, options: [])
                if let value = Value(any) {
                    results.append(value)
                }
            }
        }
        print(results.count)
    }
}
