//
//  ProductAdvantageItemViewModel.swift
//  ForwardLeasing
//

import Foundation

struct ProductAdvantageItemViewModel {
  let imageURL: URL?
  let title: String
  let content: String
  
  init(contentItem: ProductContentItem) {
    imageURL = contentItem.imageLink.toURL()
    title = contentItem.title
    content = contentItem.content
  }
}
