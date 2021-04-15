//
//  Constants.swift
//  ForwardLeasing
//

import Foundation
import UIKit

struct Constants {
  static var appName: String {
    return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
  }
  static var appVersion: String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
  }
  static var buildVersionNumber: String {
    return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
  }
  static var fullAppVersion: String {
    return Constants.appVersion + "(\(Constants.buildVersionNumber))"
  }
  static var urlScheme: String = "fwddeeplink"
  
  static let appLocale = Locale(identifier: "ru_RU")
  
  static let supportPhoneNumber = "88007707575"
  static let supportEmail = "info@forward.lc"
  
  static let appStoreID = "id1487103492"
  static let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/apple-store/" + appStoreID)
  
  static var enableLoggingToConsole: Bool = {
    if let configuration = Bundle.main.infoDictionary?["Configuration"] as? String, configuration == "Debug" {
      return true
    }
    return false
  }()
  
  static var vendorID: String? {
    return UIDevice.current.identifierForVendor?.uuidString
  }
  
  static var osVersion: String {
    return UIDevice.current.systemVersion
  }
  
  static var deviceName: String {
    return UIDevice.current.name
  }
  
  static let deviceType = "IOS"
  
  static var deviceModel: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let modelCode = withUnsafePointer(to: &systemInfo.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in
        String(validatingUTF8: ptr)
      }
    }
    return modelCode ?? ""
  }
  
  static var timeZoneOffset: Int {
    return TimeZone.current.secondsFromGMT() / 60
  }

  static let defaultChannel = "SUBSCRIBE-RF-IOS"
  static let backendLanguageIdentifier = "RU"

  static let listRequestDefaultLimit = 20

  static var maxModalScreenHeight: CGFloat {
    return UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height
  }

  static var windowSafeAreaBottomInset: CGFloat {
    return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
  }
  
  static let sumSubLocale = appLocale.identifier
  static var sumSubBaseURLString: String = {
      return PlistConfigurationManager.makeValue(from: "sumsub") as? String ?? "test-msdk.sumsub.com"
    }()

  static let phoneInitialValue = "+7"

  static var isIOS13Available: Bool {
    if #available(iOS 13.0, *) {
      return true
    } else {
      return false
    }
  }
}
