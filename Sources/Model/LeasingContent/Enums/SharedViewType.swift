//
//  SharedViewType.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

enum SharedViewType: String, Codable {
  case cropped
  case fullVertical = "full_vertical"
  case fullHorizontal = "full_horizontal"
  case nontransparentBg = "nontransparent_bg"
}
