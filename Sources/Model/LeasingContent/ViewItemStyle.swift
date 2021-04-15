//
//  ViewItemStyle.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import UIKit

struct ViewItemStyle: Codable {
  enum CodingKeys: String, CodingKey {
    case viewStyle, viewAlign, bgColor, bgStyle, fontColor
    
    case bgURL = "bgUrl"
    case fgURL = "fgUrl"
  }
  
  enum ViewStyle: String, Codable {
    case big
    case medium
    case small
    case text
    case modelStyle = "model_style"
    case categoryStyle = "category_style"
    case textButton = "text_button"
  }
  
  enum ViewAlign: String, Codable {
    case top
    case bottom
    case none
    
    var stackViewAlignment: UIStackView.Alignment {
      switch self {
      case .bottom:
        return .bottom
      case .none:
        return .center
      default:
        return .top
      }
    }
  }
  
  let viewStyle: ViewStyle
  let viewAlign: ViewAlign
  let bgColor: String?
  let bgStyle: SharedBgStyle
  let fontColor: String?
  let bgURL: String?
  let fgURL: String?
}
