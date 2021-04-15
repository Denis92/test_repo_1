//
//  UIColor+isLight.swift
//  ForwardLeasing
//

import UIKit

extension UIColor {
  func isLight(threshold: Float = 0.5) -> Bool? {
    let rgbColor = cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
    guard let components = rgbColor?.components, components.count >= 3 else { return nil }

    let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
    return (brightness > threshold)
  }
}
