//
//  BannerShowing.swift
//  ForwardLeasing
//

import UIKit

protocol BannerShowing {
  func showBanner(text: String?, onBannerTapped: (() -> Void)?)
  func showBanner(text: String?)
}

extension BannerShowing {
  func showBanner(text: String?) {
    showBanner(text: text, onBannerTapped: nil)
  }
  
  func showErrorBanner(error: Error?) {
    guard let error = error else { return }
    BannerShowingUtility.showNotificationBanner(bannerType: .error(error),
                                                onBannerTapped: nil)
  }

  func showBanner(text: String?, onBannerTapped: (() -> Void)?) {
    guard let text = text else { return }
    BannerShowingUtility.showNotificationBanner(bannerType: .info(text), onBannerTapped: onBannerTapped)
  }
}

extension UIViewController: BannerShowing { }

extension UIView: BannerShowing { }
