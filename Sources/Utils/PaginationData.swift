//
//  PaginationData.swift
//  ForwardLeasingTests
//

import Foundation

class PaginationData<T> {
  private(set) var objects: [T]
  private(set) var hasMoreData: Bool
  private(set) var limit: Int
  private(set) var offset: Int

  var page: Int {
    return offset / limit
  }

  var count: Int {
    return objects.count
  }

  var isEmpty: Bool {
    return objects.isEmpty
  }

  init(limit: Int = Constants.listRequestDefaultLimit) {
    self.objects = []
    self.offset = 0
    self.hasMoreData = true
    self.limit = limit
  }

  func item(at index: Int) -> T? {
    return objects.element(at: index)
  }

  func replaceItem(at index: Int, with object: T) {
    guard !objects.indexOutOfRange(index) else { return }
    objects[index] = object
  }

  func appendObjects(_ array: [T]) {
    offset += array.count
    objects += array
    hasMoreData = array.count >= limit
  }

  func allObjects() -> [T] {
    return objects
  }

  func setToDoesntHaveMoreData() {
    hasMoreData = false
  }

  func reset() {
    objects.removeAll()
    offset = 0
    hasMoreData = true
  }

  @discardableResult func remove(at index: Int) -> T? {
    guard objects.indexOutOfRange(index) else { return nil }
    offset -= 1
    return objects.remove(at: index)
  }

  func insert(_ newElement: T, at index: Int) {
    offset += 1
    objects.insert(newElement, at: index)
  }

  subscript(index: Int) -> T {
    get { return objects[index] }
    set { objects[index] = newValue }
  }
}
