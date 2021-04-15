//
//  StoryItem.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct StoryItem: Codable {
  enum CodingKeys: String, CodingKey {
    case pageNumber, actionLink, storyTexts
    
    case imgURL = "imgUrl"
  }
  
  let pageNumber: Int
  let imgURL: String
  let actionLink: ActionLink?
  let storyTexts: [MarketingText]?
}
