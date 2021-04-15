//
//  TextInputLayoutType.swift
//  ForwardLeasing
//

import Foundation
import CoreGraphics

enum PartialWidthLayoutPosition {
  case first, last
}

enum TextInputLayoutType {
  case fullWidth, partialWidthStretching(position: PartialWidthLayoutPosition),
       partialWidthFixed(width: CGFloat, position: PartialWidthLayoutPosition)
}
