//
//  BannerShowingUtility.swift
//  ForwardLeasing
//

import Foundation
import NotificationBannerSwift

private extension Constants {
  static let defaultDuration: TimeInterval = 3
}

enum BannerType {
  case error(Error)
  case info(String)
}

extension BannerType {
  var description: String {
    switch self {
    case .error(let error):
      return error.localizedDescription
    case .info(let text):
      return text
    }
  }

  var style: BannerStyle {
    switch self {
    case .error:
      return .danger
    default:
      return .info
    }
  }

  var dismissDuration: TimeInterval {
    return Constants.defaultDuration
  }
}

struct BannerShowingUtility {
  private static var currentBanner: GrowingNotificationBanner?
  private static var notificationDismissWorkItem: DispatchWorkItem?

  static func showNotificationBanner(bannerType: BannerType, onBannerTapped: (() -> Void)? = nil) {
    let banner = GrowingNotificationBanner(title: "",
                                           subtitle: bannerType.description,
                                           style: bannerType.style,
                                           colors: CustomBannerColors())
    banner.subtitleLabel?.font = .textRegular
    banner.subtitleLabel?.textColor = .base2

    banner.bannerQueue.removeAll()
    currentBanner?.dismiss()
    self.notificationDismissWorkItem?.cancel()

    banner.show(queuePosition: .back)
    currentBanner = banner

    banner.autoDismiss = false
    banner.onTap = {
      onBannerTapped?()
      self.dismiss(banner: banner)
    }
    banner.onSwipeUp = {
      self.dismiss(banner: banner)
    }

    let duration = bannerType.dismissDuration
    let notificationDismissWorkItem = DispatchWorkItem {
      self.dismiss(banner: banner)
    }
    self.notificationDismissWorkItem = notificationDismissWorkItem
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration, execute: notificationDismissWorkItem)
  }

  private static func dismiss(banner: GrowingNotificationBanner) {
    let dismissDuration = banner.animationDuration
    banner.dismiss()
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + dismissDuration) {
      self.currentBanner = nil
    }
  }
}
