//
//  CatalogueNavigationItem.swift
//  ForwardLeasing
//

import Foundation

enum NavigationItemType: String, Codable {
  case category, model, subscription, promo
}

struct CatalogueNavigationItem {
  let type: NavigationItemType
  let name: String?
  let imageURL: String?
  let colorHEX: String?
}
