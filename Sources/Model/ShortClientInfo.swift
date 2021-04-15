//
//  ShortClientInfo.swift
//  ForwardLeasing
//

import Foundation

struct ShortClientInfo: Codable {
  let firstName: String
  let lastNameMasked: String
  let email: String
  let mobilePhoneMasked: String
  let sex: Sex
}
