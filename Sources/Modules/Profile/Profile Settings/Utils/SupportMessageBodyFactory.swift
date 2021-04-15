//
//  SupportMessageBodyFactory.swift
//  ForwardLeasing
//

import Foundation

struct SupportMessageBodyFactory {
  static func makeMessageBody(phoneNumber: String?) -> String {
    let platform = R.string.profileSettings.platformText(Constants.deviceType)
    let osVersion = R.string.profileSettings.osVersionText(Constants.osVersion)
    let appVersion = R.string.profileSettings.appVersionText(Constants.fullAppVersion)
    var body = [platform, osVersion, appVersion]
    if let phoneNumber = phoneNumber {
      let phone = R.string.profileSettings.phoneNumberText(phoneNumber)
      body.append(phone)
    }
    return body.joined(separator: "\n")
  }
}
