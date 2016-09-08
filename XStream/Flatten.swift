//
//  Flatten.swift
//  XStream
//
//  Created by Daniel Tartaglia on 9/6/16.
//  Copyright © 2016 Daniel Tartaglia. MIT License.
//

import Foundation


extension StreamConvertable where Value: StreamConvertable
{
	public func flatten<S: StreamConvertable where S.Value == Value>() -> Stream<Value.Value> {
		let op = FlattenOperator(inStream: self.asStream())
		return Stream(producer: op)
	}
}


private
class FlattenOperator<T: StreamConvertable>: Listener, Producer
{
	typealias ListenerValue = T
	typealias ProducerValue = T.Value

	private let inStream: Stream<T>
	private var removeToken: Stream<T>.RemoveToken?
	private var outStream: AnyListener<T.Value>?
	private var innerStream: Stream<T.Value>?
	private var innerListener: FlattenListener<T.Value>?
	private var innerRemoveToken: Stream<T.Value>.RemoveToken?
	private var open: Bool = true
	
	private init(inStream: Stream<T>) {
		self.inStream = inStream
	}
	
	func start<L : Listener where ProducerValue == L.ListenerValue>(listener: L) {
		outStream = AnyListener(listener)
		removeToken = inStream.addListener(self)
		open = true
	}
	
	func stop() {
		guard let removeToken = removeToken else { return }
		inStream.removeListener(removeToken)
		outStream = nil
	}
	
	func next(value: ListenerValue) {
		let newStream = value.asStream()
		removeInner()
		guard let outStream = outStream else { return }
		innerStream = newStream
		innerListener = FlattenListener<T.Value>(outStream: outStream, finished: self.less)
		innerRemoveToken = newStream.add(AnyListener(innerListener!))
	}
	
	func complete() {
		open = false
		less()
	}
	
	func error(err: ErrorType) {
		removeInner()
		outStream?.error(err)
	}
	
	func removeInner() {
		guard let innerRemoveToken = innerRemoveToken else { return }
		innerStream?.removeListener(innerRemoveToken)
		innerStream = nil
		innerListener = nil
		self.innerRemoveToken = nil
	}
	
	func less() {
		if open == false && innerStream == nil {
			outStream?.complete()
		}
	}
}


private
class FlattenListener<T>: Listener
{
	let outStream: AnyListener<T>
	let finished: () -> Void
	
	typealias ListenerValue = T

	init(outStream: AnyListener<T>, finished: () -> Void) {
		self.outStream = outStream
		self.finished = finished
	}
	
	func next(value: ListenerValue) {
		outStream.next(value)
	}
	
	func complete() {
		finished()
	}
	
	func error(err: ErrorType) {
		outStream.error(err)
	}
}