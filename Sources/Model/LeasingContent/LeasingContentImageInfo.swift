//
//  LeasingContentImageInfo.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct LeasingContentImageInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case type, height, width, viewType
    
    case imgURL = "imgUrl"
    case thumbURL = "thumbUrl"
  }
  
  enum ImageInfoType: String, Codable {
    case primary = "PRIMARY"
    case common = "COMMON"
  }
  
  let type: ImageInfoType
  let imgURL: String
  let thumbURL: String?
  let height: Int?
  let width: Int?
  let viewType: SharedViewType
}
