import Automerge
import XCTest

final class EnumAssociatedValueTests: XCTestCase {
    var doc: Document!
    var encoder: AutomergeEncoder!
    var decoder: AutomergeDecoder!

    override func setUp() {
        doc = Document()
        encoder = AutomergeEncoder(doc: doc)
        decoder = AutomergeDecoder(doc: doc)
    }

    // MARK: - Test Data Structures

    struct SimpleStruct: Codable, Equatable {
        let value: String
    }

    struct ComplexStruct: Codable, Equatable {
        let name: String
        let count: Int
        let flag: Bool
    }

    struct NestedStruct: Codable, Equatable {
        let inner: SimpleStruct
        let number: Int
    }

    // MARK: - Baseline: Enum with Primitive Associated Values (Should Work)

    enum PrimitiveEnum: Codable, Equatable {
        case string(String)
        case integer(Int)
        case boolean(Bool)
        case double(Double)
    }

    func testEnumWithStringAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: PrimitiveEnum
        }

        let sample = Wrapper(value: .string("test"))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithIntAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: PrimitiveEnum
        }

        let sample = Wrapper(value: .integer(42))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithBoolAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: PrimitiveEnum
        }

        let sample = Wrapper(value: .boolean(true))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithDoubleAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: PrimitiveEnum
        }

        let sample = Wrapper(value: .double(3.14159))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    // MARK: - Bug Test: Enum with Struct Associated Value (Expected to Fail)

    enum StructEnum: Codable, Equatable {
        case simple(SimpleStruct)
        case complex(ComplexStruct)
        case nested(NestedStruct)
    }

    func testEnumWithSimpleStructAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: StructEnum
        }

        let sample = Wrapper(value: .simple(SimpleStruct(value: "test")))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithComplexStructAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: StructEnum
        }

        let sample = Wrapper(value: .complex(ComplexStruct(
            name: "henry",
            count: 42,
            flag: true
        )))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithNestedStructAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: StructEnum
        }

        let sample = Wrapper(value: .nested(NestedStruct(
            inner: SimpleStruct(value: "nested"),
            number: 7
        )))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    // MARK: - Bug Test: Enum with Optional Struct (Data Loss)

    enum OptionalStructEnum: Codable, Equatable {
        case optionalSimple(SimpleStruct?)
        case optionalComplex(ComplexStruct?)
    }

    func testEnumWithOptionalStructAssociatedValue_nil() throws {
        struct Wrapper: Codable, Equatable {
            let value: OptionalStructEnum
        }

        let sample = Wrapper(value: .optionalSimple(nil))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithOptionalStructAssociatedValue_present() throws {
        struct Wrapper: Codable, Equatable {
            let value: OptionalStructEnum
        }

        let sample = Wrapper(value: .optionalSimple(SimpleStruct(value: "test")))

        try encoder.encode(sample)

        // This currently decodes as nil (data loss)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithOptionalComplexStructAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: OptionalStructEnum
        }

        let sample = Wrapper(value: .optionalComplex(ComplexStruct(
            name: "test",
            count: 5,
            flag: false
        )))

        try encoder.encode(sample)

        // This currently decodes as nil (data loss)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    // MARK: - Optional Primitive Tests (Should Work)

    enum OptionalPrimitiveEnum: Codable, Equatable {
        case optionalString(String?)
        case optionalInt(Int?)
    }

    func testEnumWithOptionalPrimitiveAssociatedValue_nil() throws {
        struct Wrapper: Codable, Equatable {
            let value: OptionalPrimitiveEnum
        }

        let sample = Wrapper(value: .optionalString(nil))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithOptionalPrimitiveAssociatedValue_present() throws {
        struct Wrapper: Codable, Equatable {
            let value: OptionalPrimitiveEnum
        }

        let sample = Wrapper(value: .optionalString("test"))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    // MARK: - Multiple Associated Values (Mixed Types)

    enum MultipleAssociatedEnum: Codable, Equatable {
        case primitives(String, Int)
        case mixed(String, SimpleStruct)
        case structs(SimpleStruct, ComplexStruct)
    }

    func testEnumWithMultiplePrimitiveAssociatedValues() throws {
        struct Wrapper: Codable, Equatable {
            let value: MultipleAssociatedEnum
        }

        let sample = Wrapper(value: .primitives("test", 42))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithMixedPrimitiveAndStructAssociatedValues() throws {
        struct Wrapper: Codable, Equatable {
            let value: MultipleAssociatedEnum
        }

        let sample = Wrapper(value: .mixed("test", SimpleStruct(value: "inner")))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithMultipleStructAssociatedValues() throws {
        struct Wrapper: Codable, Equatable {
            let value: MultipleAssociatedEnum
        }

        let sample = Wrapper(value: .structs(
            SimpleStruct(value: "first"),
            ComplexStruct(name: "second", count: 10, flag: true)
        ))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    // MARK: - Deeply Nested Cases

    enum DeeplyNestedEnum: Codable, Equatable {
        case nested(NestedStruct)
    }

    func testEnumWithDeeplyNestedStruct() throws {
        struct Wrapper: Codable, Equatable {
            let value: DeeplyNestedEnum
        }

        let sample = Wrapper(value: .nested(NestedStruct(
            inner: SimpleStruct(value: "deep"),
            number: 99
        )))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    // MARK: - Edge Case: Enum in Array

    func testArrayOfEnumsWithStructAssociatedValues() throws {
        struct Wrapper: Codable, Equatable {
            let values: [StructEnum]
        }

        let sample = Wrapper(values: [
            .simple(SimpleStruct(value: "first")),
            .complex(ComplexStruct(name: "second", count: 5, flag: false)),
            .simple(SimpleStruct(value: "third")),
        ])

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    // MARK: - Edge Case: Enum with Special Types

    enum SpecialTypesEnum: Codable, Equatable {
        case url(URL)
        case uuid(UUID)
        case date(Date)
        case data(Data)
    }

    func testEnumWithURLAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: SpecialTypesEnum
        }

        let sample = Wrapper(value: .url(URL(string: "https://example.com")!))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithUUIDAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: SpecialTypesEnum
        }

        let sample = Wrapper(value: .uuid(UUID(uuidString: "99CEBB16-1062-4F21-8837-CF18EC09DCD7")!))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithDateAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: SpecialTypesEnum
        }

        let dateFormatter = ISO8601DateFormatter()
        let testDate = dateFormatter.date(from: "2023-06-05T17:00:00Z")!

        let sample = Wrapper(value: .date(testDate))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    func testEnumWithDataAssociatedValue() throws {
        struct Wrapper: Codable, Equatable {
            let value: SpecialTypesEnum
        }

        let sample = Wrapper(value: .data(Data("test data".utf8)))

        try encoder.encode(sample)
        let decoded = try decoder.decode(Wrapper.self)

        XCTAssertEqual(sample, decoded)
    }

    // MARK: - Direct Encoding Without Wrapper (Test at Root Level)

    func testDirectEnumWithStructAtRoot() throws {
        let sample = StructEnum.simple(SimpleStruct(value: "root"))

        try encoder.encode(sample)
        let decoded = try decoder.decode(StructEnum.self)

        XCTAssertEqual(sample, decoded)
    }

    func testDirectEnumWithPrimitiveAtRoot() throws {
        let sample = PrimitiveEnum.string("root")

        try encoder.encode(sample)
        let decoded = try decoder.decode(PrimitiveEnum.self)

        XCTAssertEqual(sample, decoded)
    }

}
