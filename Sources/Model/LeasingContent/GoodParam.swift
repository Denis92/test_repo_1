//
//  GoodParam.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct GoodParam: Codable {
  enum GoodParamType: String, Codable {
    case volume
    case color
    case diagonal
    case connection
    case cpu
    case os
  }
  
  let type: GoodParamType
  let name: String
  let value: String
}
