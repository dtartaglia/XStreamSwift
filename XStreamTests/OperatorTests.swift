//
//  MapTests.swift
//  XStream
//
//  Created by Daniel Tartaglia on 9/4/16.
//  Copyright © 2016 Daniel Tartaglia. MIT License.
//

import XCTest
@testable import XStream


final class OperatorTests: XCTestCase {
	
	func testMap() {
		let stream = XStream.Stream(from: [1, 2, 3]).map { $0 * 10 }
		let expected = [10, 20, 30]
		var index = 0
		var completeCalled = false

		let _ = stream.add(listener: AnyListener<Int>(next: { val in
			XCTAssert(val == expected[index])
			index += 1
		}, complete: {
			completeCalled = true
		}, error: { _ in
			XCTFail()
		}))
		
		XCTAssert(completeCalled)
		XCTAssert(index == expected.count)
	}

	func testPrefix() {
		let stream = XStream.Stream(from: [1, 2, 3, 4, 5]).prefix(3)
		let expected = [1, 2, 3]
		var index = 0
		var completeCalled = false
		
		let _ = stream.add(listener: AnyListener<Int>(next: { val in
			XCTAssert(val == expected[index])
			index += 1
		}, complete: {
			XCTAssert(completeCalled == false)
			completeCalled = true
		}, error: { _ in
			XCTFail()
		}))
		
		XCTAssert(completeCalled)
		XCTAssert(index == expected.count)
	}

	func testPrefixWhile() {
		let stream = XStream.Stream(from: [1, 2, 3, 4, 5]).prefix(while: { $0 < 4 })
		let expected = [1, 2, 3]
		var index = 0
		var completeCalled = false

		let _ = stream.add(listener: AnyListener<Int>(next: { val in
			XCTAssert(val == expected[index])
			index += 1
		}, complete: {
			XCTAssert(completeCalled == false)
			completeCalled = true
		}, error: { _ in
			XCTFail()
		}))

		XCTAssert(completeCalled)
		XCTAssert(index == expected.count)
	}

	func testDropFirst() {
		let stream = XStream.Stream(from: [1, 2, 3, 4, 5]).dropFirst(3)
		let expected = [4, 5]
		var index = 0
		var completeCalled = false

		let _ = stream.add(listener: AnyListener<Int>(next: { val in
			XCTAssert(val == expected[index])
			index += 1
		}, complete: {
			completeCalled = true
		}, error: { _ in
			XCTFail()
		}))

		XCTAssert(completeCalled)
		XCTAssert(index == expected.count)
	}

	func testDropLast() {
		let stream = XStream.Stream(from: [1, 2, 3, 4, 5]).dropLast(3)
		let expected = [1, 2]
		var index = 0
		var completeCalled = false

		let _ = stream.add(listener: AnyListener<Int>(next: { val in
			XCTAssert(val == expected[index])
			index += 1
		}, complete: {
			completeCalled = true
		}, error: { _ in
			XCTFail()
		}))

		XCTAssert(completeCalled)
		XCTAssert(index == expected.count)
	}

	func testDropWhile() {
		let stream = XStream.Stream(from: [1, 2, 3, 4, 5]).drop(while: { $0 < 3 })
		let expected = [3, 4, 5]
		var index = 0
		var completeCalled = false

		let _ = stream.add(listener: AnyListener<Int>(next: { val in
			XCTAssert(val == expected[index])
			index += 1
		}, complete: {
			completeCalled = true
		}, error: { _ in
			XCTFail()
		}))

		XCTAssert(completeCalled)
		XCTAssert(index == expected.count)
	}

	func testLast() {
		let stream = XStream.Stream(from: [1, 2, 3, 4, 5]).suffix(2)
		let expected = [4, 5]
		var index = 0
		var completeCalled = false
		
		let _ = stream.add(listener: AnyListener<Int>(next: { val in
			XCTAssert(val == expected[index])
			index += 1
		}, complete: {
			completeCalled = true
		}, error: { _ in
			XCTFail()
		}))
		
		XCTAssert(completeCalled)
		XCTAssert(index == expected.count)
	}
	
	func testStartWith() {
		let stream = XStream.Stream(from: [1, 2, 3, 4, 5]).startWith(0)
		let expected = [0, 1, 2, 3, 4, 5]
		var index = 0
		var completeCalled = false
		
		let _ = stream.add(listener: AnyListener<Int>(next: { val in
			XCTAssertEqual(val, expected[index])
			index += 1
		}, complete: {
			completeCalled = true
		}, error: { _ in
			XCTFail()
		}))
		
		XCTAssert(completeCalled)
		XCTAssert(index == expected.count)
	}
	
	func testEndWhenCompletesOnNext() {
		let expectation = self.expectation(description: "testEndWhenCompletesOnNext")
		let source = periodicStream(0.2)
		let other = periodicStream(0.9)
		let stream = source.endWhen(other)
		let expected = [0, 1, 2, 3]
		var index = 0

		let _ = stream.add(listener: AnyListener<Int>(next: { val in
			XCTAssert(val == expected[index])
			index += 1
		}, complete: {
			XCTAssertEqual(index, expected.count)
			expectation.fulfill()
		}, error: { _ in
			XCTFail()
		}))
		
		self.waitForExpectations(timeout: 10.0) { _ in }
	}
	
	func testFold() {
		let expectation = self.expectation(description: "testFold")
		let stream = periodicStream(0.20).prefix(4).fold(0) { $0 + $1 }
		let expected = [0, 0, 1, 3, 6]
		var index = 0
		
		let _ = stream.add(listener: AnyListener<Int>(next: { val in
			XCTAssertEqual(val, expected[index])
			index += 1
		}, complete: {
			XCTAssertEqual(index, expected.count)
			expectation.fulfill()
		}, error: { _ in
			XCTFail()
		}))
		
		self.waitForExpectations(timeout: 1.0) { _ in }
	}

	func testDebugInspecting() {
		let expectation = self.expectation(description: "testDebugInspecting")
		let expected = [0, 1, 2]
		var index = 0
		let stream = periodicStream(0.20).prefix(3).debug {
			XCTAssertEqual($0, expected[index])
			index += 1
		}
		let listener = AnyListener<Int>(next: {
			if $0 == 2 {
				XCTAssertEqual(index, expected.count)
				expectation.fulfill()
			}
		}, complete: { }, error: { _ in XCTFail() })
		let _ = stream.add(listener: listener)
		self.waitForExpectations(timeout: 1.0) { _ in }
	}
}
