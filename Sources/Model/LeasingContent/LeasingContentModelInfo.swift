//
//  LeasingContentModelInfo.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct LeasingContentModelInfo: Codable {
  struct Producer: Codable {
    let code: String
    let name: String
  }
  
  enum MarketingLabel: String, Codable {
    case bestseller = "BESTSELLER"
    case new = "NEW"
    case present = "PRESENT"
    case preorder = "PREORDER"
  }
  
  struct ModelType: Codable {
    let code: String
    let name: String
  }
  
  let code: String
  let name: String
  let producer: Producer
  let marketingLabel: String?
  let modelType: ModelType
  let favoriteGoods: [GoodInfo]
  let tagCodes: [String]?
}
