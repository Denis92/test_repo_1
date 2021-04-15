//
//  ViewItem.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct ViewItem: Codable {
  enum ViewItemType: String, Codable {
    case category
    case model
    case subscription
    case banner
    case story
    case group
    case tag
    case good
  }
  
  let type: ViewItemType
  let itemCode: String?
  let viewItemStyle: ViewItemStyle?
  let childItems: [ViewItem]?
  let category: CategoryInfo?
  let model: LeasingContentModelInfo?
  let subscription: SubscriptionInfo?
  let banner: BannerInfo?
  let story: StoryInfo?
  let good: GoodInfo?
}
