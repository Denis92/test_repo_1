//
//  MulticastDelegate.swift
//  ForwardLeasing
//

import Foundation

class MulticastDelegate<T> {
  private var delegates: [Weak] = []
  
  var hasNoDelegates: Bool {
    delegates = delegates.filter { $0.value != nil }
    return delegates.isEmpty
  }
  
  public func add(_ delegate: T) {
    delegates.append(Weak(value: delegate as AnyObject))
  }
  
  public func remove(_ delegate: T) {
    let weak = Weak(value: delegate as AnyObject)
    if let index = delegates.firstIndex(of: weak) {
      delegates.remove(at: index)
    }
  }
  
  func invoke(_ invocation: @escaping (T) -> Void) {
    delegates = delegates.filter { $0.value != nil }
    delegates.forEach {
      if let delegate = $0.value as? T {
        invocation(delegate)
      }
    }
  }
}

private struct Weak: Equatable {
  weak var value: AnyObject?
  
  static func == (lhs: Weak, rhs: Weak) -> Bool {
    return lhs.value === rhs.value
  }
}
