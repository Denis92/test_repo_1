//
//  StoryInfo.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct StoryInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case code, caption, storyItems, viewType
    
    case imgURL = "imgUrl"
  }
  
  let code: String
  let imgURL: String
  let caption: String
  let storyItems: [StoryItem]
  let viewType: SharedViewType?
}
