//
//  MemoryStream.swift
//  XStream
//
//  Created by Daniel Tartaglia on 9/3/16.
//  Copyright © 2016 Daniel Tartaglia. MIT License.
//

import Foundation


final class MemoryStream<T>: Stream<T>
{
	override init<P: Producer>(producer: P) where P.ProducerValue == Value {
		super.init(producer: producer)
	}
	
	override func next(_ value: Value) {
		lastValue = value
		nextCalled = true
		super.next(value)
	}
	
	override func add(listener: ListenerType) -> RemoveToken {
		if let value = lastValue, nextCalled {
			listener.next(value)
		}
		let result = super.add(listener: listener)
		return result
	}

	private var lastValue: Value? = nil
	private var nextCalled = false // nextCalled is required to support Value == Void type
}
