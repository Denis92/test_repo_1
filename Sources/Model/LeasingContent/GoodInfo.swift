//
//  GoodInfo.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct GoodInfo: Codable {
  let onSale: Bool
  let code: String
  let name: String
  let price: Int
  let isDefault: Bool
  let labelViews: [ContentLabelView]?
  let leasingInfo: LeasingProduct?
  let leasingOptions: [LeasingProduct]?
  let images: [LeasingContentImageInfo]?
  let params: [GoodParam]?
}
