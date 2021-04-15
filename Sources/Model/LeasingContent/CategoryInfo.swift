//
//  CategoryInfo.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct CategoryInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case code, name, defaultGoodCode
    
    case imgURL = "imgUrl"
  }
  
  let code: String
  let name: String
  let imgURL: String?
  let defaultGoodCode: String?
}
