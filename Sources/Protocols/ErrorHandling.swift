//
//  ErrorHandling.swift
//  ForwardLeasing
//

import UIKit

protocol ErrorHandling {
  func handle(error: Error?)
}

extension ErrorHandling {
  func handle(error: Error?) {
    guard let error = error, error is LocalizedError
      || !((error as NSError).userInfo[NSLocalizedDescriptionKey] as? String).isEmptyOrNil,
      !error.localizedDescription.isEmpty else { return }
    BannerShowingUtility.showNotificationBanner(bannerType: .error(error))
  }
}

extension UIViewController: ErrorHandling { }

extension UIView: ErrorHandling { }
