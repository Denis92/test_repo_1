//
//  SubscriptionInfo.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct SubscriptionInfo: Codable {
  let name: String
  let group: String
  let items: [SubscriptionItem]
}
