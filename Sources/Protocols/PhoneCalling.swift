//
//  PhoneCalling.swift
//  ForwardLeasing
//

import UIKit

protocol PhoneCalling {
  func callIfCan(phoneNumber: String?)
}

extension PhoneCalling {
  func callIfCan(phoneNumber: String?) {
    guard let phone = phoneNumber, let phoneURL = URLFactory.phoneNumber(phone: phone),
          UIApplication.shared.canOpenURL(phoneURL) else { return }
    UIApplication.shared.open(phoneURL)
  }
}
