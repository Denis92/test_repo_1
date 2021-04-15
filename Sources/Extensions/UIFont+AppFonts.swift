//
//  UIFont+AppFonts.swift
//  ForwardLeasing
//

import UIKit

extension UIFont {
  // MARK: - App fonts
  
  private struct FontNames {
    static let bold = "ProximaNova-Bold"
    static let regular = "ProximaNova-Regular"
    static let semibold = "ProximaNova-Semibold"
  }
  
  static let title0Bold = UIFont.boldAppFont(ofSize: 35)
  static let title1Bold = UIFont.boldAppFont(ofSize: 30)
  static let title2Bold = UIFont.boldAppFont(ofSize: 20)
  static let title2Semibold = UIFont.semiboldAppFont(ofSize: 20)
  static let title2Regular = UIFont.appFont(ofSize: 20)
  static let h3 = UIFont.semiboldAppFont(ofSize: 18)
  static let title3Semibold = UIFont.semiboldAppFont(ofSize: 17)
  static let title3Regular = UIFont.appFont(ofSize: 17)
  static let headlineRegular = UIFont.appFont(ofSize: 16)
  static let bodyBold = UIFont.semiboldAppFont(ofSize: 16)
  static let textBold = UIFont.boldAppFont(ofSize: 15)
  static let textSemibold = UIFont.semiboldAppFont(ofSize: 15)
  static let textRegular = UIFont.appFont(ofSize: 15)
  static let subheadRegular = UIFont.appFont(ofSize: 14)
  static let footnoteRegular = UIFont.appFont(ofSize: 12)
  static let caption2Semibold = UIFont.semiboldAppFont(ofSize: 11)
  static let caption3Regular = UIFont.appFont(ofSize: 10)
  
  static func appFont(ofSize size: CGFloat) -> UIFont {
    guard let font = UIFont(name: FontNames.regular, size: size) else {
      log.debug("Failed to load the \(FontNames.regular) font, system font will be used")
      return .systemFont(ofSize: size)
    }
    return font
  }
  
  static func semiboldAppFont(ofSize size: CGFloat) -> UIFont {
    guard let font = UIFont(name: FontNames.semibold, size: size) else {
      log.debug("Failed to load the \(FontNames.semibold) font, system font will be used")
      return .systemFont(ofSize: size)
    }
    return font
  }
  
  static func boldAppFont(ofSize size: CGFloat) -> UIFont {
    guard let font = UIFont(name: FontNames.bold, size: size) else {
      log.debug("Failed to load the \(FontNames.bold) font, system font will be used")
      return .systemFont(ofSize: size, weight: .bold)
    }
    return font
  }
}
