import XCTest
@testable import Serialize
import SerializableValues

class DeserializeTests: XCTestCase {
    func testBoolAtom() {
        XCTAssertEqual(Value.bool(true), try deserialize("true"))
        XCTAssertEqual(Value.bool(false), try deserialize("false"))
    }
    
    func testDoubleAtom() {
        XCTAssertEqual(Value.double(Double(5.555666777)), try deserialize("5.555666777"))
    }
    
    func testFloatAtom() {
        XCTAssertEqual(Value.float(1.1), try deserialize("1.1"))
    }
    
    func testIntAtom() {
        XCTAssertEqual(Value.int(1), try deserialize("1"))
    }
    
    func testStringAtom() {
        XCTAssertEqual(Value.string("hello"), try deserialize("\"hello\""))
    }
}
