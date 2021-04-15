//
//  TextStyle.swift
//  ForwardLeasing
//

import UIKit

enum TextStyle {
  case title0Bold, title1Bold, title2Bold, title2Semibold, title2Regular, title3Semibold,
       title3Regular, headlineRegular, textBold, textSemibold, textRegular, subheadRegular,
       footnoteRegular, caption2Semibold, caption3Regular, h3, bodyBold

  var font: UIFont {
    switch self {
    case .title0Bold:
      return .title0Bold
    case .title1Bold:
      return .title1Bold
    case .title2Bold:
      return .title2Bold
    case .title2Semibold:
      return .title2Semibold
    case .title2Regular:
      return .title2Regular
    case .title3Semibold:
      return .title3Semibold
    case .title3Regular:
      return .title3Regular
    case .headlineRegular:
      return .headlineRegular
    case .bodyBold:
      return .bodyBold
    case .textBold:
      return .textBold
    case .textSemibold:
      return .textSemibold
    case .textRegular:
      return .textRegular
    case .subheadRegular:
      return .subheadRegular
    case .footnoteRegular:
      return .footnoteRegular
    case .caption2Semibold:
      return .caption2Semibold
    case .caption3Regular:
      return .caption3Regular
    case .h3:
      return .h3
    }
  }

  var lineHeight: CGFloat {
    switch self {
    case .title0Bold:
      return 40
    case .title1Bold:
      return 38
    case .title2Bold, .title2Semibold, .title2Regular:
      return 24
    case .title3Semibold, .title3Regular, .bodyBold:
      return 22
    case .headlineRegular, .textBold, .textSemibold, .textRegular:
      return 20
    case .h3:
      return 18
    case .subheadRegular:
      return 16
    case .footnoteRegular, .caption2Semibold, .caption3Regular:
      return 14
    }
  }

  var kern: CGFloat {
    switch self {
    case .title0Bold:
      return 0.33
    case .title1Bold:
      return 0
    case .title2Bold:
      return 0
    case .title2Semibold:
      return 0.6
    case .title2Regular:
      return 0
    case .title3Semibold:
      return -0.38
    case .title3Regular:
      return -0.41
    case .headlineRegular:
      return -0.32
    case .textBold:
      return 0
    case .textSemibold:
      return 0.76
    case .textRegular:
      return -0.24
    case .subheadRegular:
      return -0.08
    case .footnoteRegular:
      return -0.08
    case .caption2Semibold:
      return 0.06
    case .caption3Regular:
      return 0.06
    case .h3, .bodyBold:
      return 0
    }
  }

  var lineHeightMultiple: CGFloat {
    switch self {
    case .title0Bold:
      return 1.14
    case .title1Bold:
      return 1.27
    case .title2Bold:
      return 1.2
    case .title2Semibold:
      return 1.2
    case .title2Regular:
      return 1.2
    case .title3Semibold:
      return 1.29
    case .title3Regular:
      return 1.29
    case .headlineRegular:
      return 1.25
    case .textBold:
      return 1.33
    case .textSemibold:
      return 1.33
    case .textRegular:
      return 1.33
    case .subheadRegular:
      return 1.14
    case .footnoteRegular:
      return 1.33
    case .caption2Semibold:
      return 1.27
    case .caption3Regular:
      return 1.4
    case .bodyBold:
      return 1.13
    case .h3:
      return 1
    }
  }
}
