import XCTest

import BinaryTargetTests

var tests = [XCTestCaseEntry]()
tests += PackageTargetTests.allTests()
XCTMain(tests)
