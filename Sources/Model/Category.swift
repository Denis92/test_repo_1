//
//  Category.swift
//  ForwardLeasing
//

import Foundation

struct Category {
  let code: String
  let title: String?
  let imageURL: String?

  init(code: String, title: String?, imageURL: String?) {
    self.code = code
    self.title = title
    self.imageURL = imageURL
  }

  init(navigationItem item: CatalogueNavigationItem) {
    // TODO: update
    code = UUID().uuidString
    title = item.name
    imageURL = item.imageURL
  }
}
