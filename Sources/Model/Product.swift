//
//  Product.swift
//  ForwardLeasing
//

import UIKit

struct Product: Codable {
  enum Size: Int, Codable {
    case small
    case medium
    case large
  }
  
  let code: String
  let title: String?
  let price: String?
  let backgroundColorHEX: String?
  let productImageURL: String?
  let type: ProductType
  let size: ViewItemStyle.ViewStyle
  let alignment: ViewItemStyle.ViewAlign

  init(code: String,
       title: String?,
       price: String?,
       backgroundColorHEX: String?,
       productImageURL: String?,
       type: ProductType = .smartphone,
       size: ViewItemStyle.ViewStyle,
       alignment: ViewItemStyle.ViewAlign) {
    self.code = code
    self.title = title
    self.price = price
    self.backgroundColorHEX = backgroundColorHEX
    self.productImageURL = productImageURL
    self.type = type
    self.size = size
    self.alignment = alignment
  }

  init(navigationItem item: CatalogueNavigationItem) {
    // TODO: update
    code = UUID().uuidString
    title = item.name
    price = "2424"
    backgroundColorHEX = "#808000"
    productImageURL = item.imageURL
    type = .smartphone
    size = .big
    alignment = .top
  }
}
