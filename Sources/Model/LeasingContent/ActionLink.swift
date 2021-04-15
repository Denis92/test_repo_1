//
//  ActionLink.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct ActionLink: Codable {
  enum ActionLinkType: String, Codable {
    case deeplink = "DEEPLINK"
    case web = "WEB"
    case extweb = "EXTWEB"
  }
  
  let type: ActionLinkType
  let url: String
  let text: String?
}
