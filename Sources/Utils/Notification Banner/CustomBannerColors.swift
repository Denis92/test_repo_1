//
//  CustomBannerColors.swift
//  ForwardLeasing
//

import UIKit
import NotificationBannerSwift

class CustomBannerColors: BannerColorsProtocol {
  internal func color(for style: BannerStyle) -> UIColor {
    switch style {
    case .danger:
      return .error
    default:
      return .base1
    }
  }
}
