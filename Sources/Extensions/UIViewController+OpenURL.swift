//
//  UIViewController+OpenURL.swift
//  ForwardLeasing
//

import UIKit

enum OpenURLError: Error {
  case badURL, failed
}

extension UIViewController {
  func openURLWithString(_ stringURL: String) throws {
    guard let linkURL = URL(string: stringURL) else {
      throw OpenURLError.badURL
    }
    try openURL(linkURL)
  }
  
  func openURL(_ linkURL: URL) throws {
    guard UIApplication.shared.canOpenURL(linkURL) else {
      throw OpenURLError.failed
    }
    UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
  }
}
