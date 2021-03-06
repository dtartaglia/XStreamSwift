//
//  Filter.swift
//  XStream
//
//  Created by Daniel Tartaglia on 9/5/16.
//  Copyright © 2016 Daniel Tartaglia. MIT License.
//

import Foundation


extension Stream
{
	/**
	Only allows events that pass the test given by the `includeElement` argument.

	Each event from the input stream is given to the `includeElement` function. If the function returns `true`, the event is forwarded to the output stream, otherwise it is ignored and not forwarded.
	*/
	public func filter(_ includeElement: @escaping (Value) throws -> Bool) -> Stream {
		let op = FilterOperator(includeElement: includeElement, inStream: self)
		return Stream(producer: op)
	}
}


private
final class FilterOperator<T>: Listener, Producer
{
	typealias ListenerValue = T
	typealias ProducerValue = T

	let inStream: Stream<T>
	var removeToken: Stream<T>.RemoveToken?
	var outStream: AnyListener<T>?
	let includeElement: (T) throws -> Bool

	init(includeElement: @escaping (T) throws -> Bool, inStream: Stream<T>) {
		self.inStream = inStream
		self.includeElement = includeElement
	}

	func start<L : Listener>(for listener: L) where ProducerValue == L.ListenerValue {
		outStream = AnyListener(listener)
		removeToken = inStream.add(listener: self)
	}

	func stop() {
		guard let removeToken = removeToken else { return }
		inStream.removeListener(removeToken)
		outStream = nil
	}

	func next(_ value: ListenerValue) {
		do {
			if try includeElement(value) {
				outStream?.next(value)
			}
		}
		catch {
			outStream?.error(error)
		}
	}

	func complete() { outStream?.complete() }

	func error(_ error: Error) { outStream?.error(error) }
	
}
