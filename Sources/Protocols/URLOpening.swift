//
//  URLOpening.swift
//  ForwardLeasing
//

import UIKit

protocol URLOpening {
  func canOpenURL(_ url: URL) -> Bool
  func open(_ url: URL)
}

extension UIApplication: URLOpening {
  func open(_ url: URL) {
    open(url, options: [:], completionHandler: nil)
  }
}
