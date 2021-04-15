//
//  BannerInfo.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct BannerInfo: Codable {
  enum BannerInfoType: String, Codable {
    case imgBannerFull = "IMG_BANNER_FULL"
    case txtSimple = "TXT_SIMPLE"
    case imgBanner = "IMG_BANNER"
    case promoGood = "PROMO_GOOD"
  }
  
  enum PlaceType: String, Codable {
    case catalogMainTop = "CATALOG_MAIN_TOP"
    case orderClose = "ORDER_CLOSE"
    case catalogInline = "CATALOG_INLINE"
    case catalogPromoModel = "CATALOG_PROMO_MODEL"
  }
  
  let type: String
  let code: String
  let placeType: String
  let priority: Int
  let cornerTexts: [MarketingText]?
  let actionLink: ActionLink?
  let bannerTexts: [MarketingText]?
}
