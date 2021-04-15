//
//  LeasingContentDeliveryInfo.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct LeasingContentDeliveryInfo: Codable {
  enum DeliveryInfoType: String, Codable {
    case pickup = "PICKUP"
    case delivery = "DELIVERY"
    
    // Needs more
  }
  
  let defaultOption: Bool
  let name: String
  let type: String
}
