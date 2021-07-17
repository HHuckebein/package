import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PackageTargetTests.allTests),
        testCase(BinaryTargetTests.allTests),
        testCase(UtilityTests.allTests)
    ]
}
#endif
