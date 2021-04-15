//
//  ContentLabel.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct ContentLabel: Codable {
  enum CodingKeys: String, CodingKey {
    case code, title, content, contentType, actionLink, hasTemplate
    
    case imgURL = "imgUrl"
  }
  
  let code: String
  let imgURL: String?
  let title: String?
  let content: String?
  let contentType: SharedContentType
  let actionLink: ActionLink?
  let hasTemplate: Bool
}
