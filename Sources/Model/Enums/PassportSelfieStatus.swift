//
//  PassportSelfieStatus.swift
//  ForwardLeasing
//

import Foundation

enum PassportSelfieStatus: String, Codable {
  case notChecked = "NOT_CHECKED"
  case pending = "PENDING"
  case rejected = "REJECTED"
  case checkedSucces = "CHECKED_SUCCESS"
  case checkOff = "CHECK_OFF"
}
