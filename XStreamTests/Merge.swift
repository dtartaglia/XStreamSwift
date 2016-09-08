//
//  Merge.swift
//  XStream
//
//  Created by Daniel Tartaglia on 9/7/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import XCTest
@testable import XStream


final class merge: XCTestCase
{
	func testMergesStreams() {
		let expectation = self.expectationWithDescription("testMergesStreams")
		let stream = Stream(streams: [periodicStream(0.8).take(2), periodicStream(1).take(2)])
		let expected = [0, 0, 1, 1]
		var index = 0
		var completeCalled = false
		
		stream.add(AnyListener<Int>(next: { val in
			XCTAssertEqual(val, expected[index])
			index += 1
		}, complete: {
			completeCalled = true
			expectation.fulfill()
		}, error: { _ in
			XCTFail()
		}))
		
		self.waitForExpectationsWithTimeout(10.0) { _ in
			XCTAssertEqual(index, expected.count)
			XCTAssert(completeCalled)
		}
	}

	func testMergesArrayOfStreams() {
		let expectation = self.expectationWithDescription("testMergesStreams")
		let stream = [periodicStream(0.8).take(2), periodicStream(1).take(2)].merge()
		let expected = [0, 0, 1, 1]
		var index = 0
		var completeCalled = false

		stream.add(AnyListener<Int>(next: { val in
			XCTAssertEqual(val, expected[index])
			index += 1
			}, complete: {
				completeCalled = true
				expectation.fulfill()
			}, error: { _ in
				XCTFail()
		}))

		self.waitForExpectationsWithTimeout(10.0) { _ in
			XCTAssertEqual(index, expected.count)
			XCTAssert(completeCalled)
		}
	}
	
	func testCompleteAfterAllComplete() {
		let expectation = self.expectationWithDescription("testCompleteAfterAllComplete")
		let stream1 = periodicStream(0.15).take(1)
		let stream2 = periodicStream(0.25).take(4)
		let stream = Stream(streams: [stream1, stream2])
		let expected = [0, 0, 1, 2, 3]
		var index = 0
		var completeCalled = false
		
		stream.add(AnyListener<Int>(next: { val in
			XCTAssertEqual(val, expected[index])
			index += 1
			}, complete: {
				completeCalled = true
				expectation.fulfill()
			}, error: { _ in
				XCTFail()
		}))
		
		self.waitForExpectationsWithTimeout(10.0) { _ in
			XCTAssertEqual(index, expected.count)
			XCTAssert(completeCalled)
		}
	}
}