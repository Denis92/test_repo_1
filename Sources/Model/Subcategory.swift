//
//  Subcategory.swift
//  ForwardLeasing
//

import Foundation

struct Subcategory {
  let code: String
  let title: String?
  let imageURL: String?

  init(code: String, title: String?, imageURL: String? = nil) {
    self.code = code
    self.title = title
    self.imageURL = imageURL
  }
}

extension Subcategory: Equatable {
  static func == (lhs: Subcategory, rhs: Subcategory) -> Bool {
    return lhs.code == rhs.code
  }
}
