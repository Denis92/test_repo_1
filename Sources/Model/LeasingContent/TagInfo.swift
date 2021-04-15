//
//  TagInfo.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct TagInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case code, name, description, bgColor, bgStyle, count, selected
    
    case imgURL = "imgUrl"
  }
  
  let code: String
  let name: String
  let description: String?
  let imgURL: String?
  let bgColor: String?
  let bgStyle: SharedBgStyle
  let count: Int?
  let selected: Bool
}
