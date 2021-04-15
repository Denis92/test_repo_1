//
//  LeasingContentResponse.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/14/21.
//

import Foundation

struct LeasingContentResponse: Decodable {
  struct PageCountInfo: Codable {
//    let itemFrom: Int
//    let itemTo: Int
//    let itemTotalWithFilter: Int
//    let itemTotal: Int
//    let pageSize: Int
//    let pageNumber: Int
  }
  
  struct FilterInfo: Codable {
    struct FilterOption: Codable {
      let name: String
      let value: String
      let selected: Bool
      let count: Int
    }
    
    let name: String
    let code: String
    let filterOptions: [FilterOption]
    let selected: Bool
  }
  
  let headerNavigations: [ViewItem]
  let content: [ViewItem]
  let pageInfo: PageCountInfo?
  let filters: [FilterInfo]?
  let labels: [String: ContentLabel]?
  let tags: [TagInfo]?
}
