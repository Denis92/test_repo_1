//
//  MarketingText.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct MarketingText: Codable {
  enum Place: String, Codable {
    case topLeft = "TL"
    case topRight = "TR"
    case bottomLeft = "BL"
    case bottomRight = "BR"
    case title
    case content
  }
  
  let place: Place
  let text: String
  let color: String?
  let contentType: SharedContentType
}
