//
//  UserDataStoreProtocols.swift
//  ForwardLeasing
//

import Foundation

protocol TokenStoring: class {
  var accessToken: String? { get set }
}

protocol UserDataStoring: class {
  var isLoggedIn: Bool { get }
  var phoneNumber: String? { get set }
  var userID: String { get }
  var occupationOptions: [OccupationData] { get set }
  var smsRepeatTimeout: Int { get set }
  var hasShownApplicationOnboarding: Bool { get }
  var hasShownExchangeOnboarding: Bool { get set }
  var hasShownReturnOnboarding: Bool { get set }
  var lastDiagnosticSessionID: String? { get set }

  func clearAuthData()
  func clearData()
  func markApplicationOnboardingAsShown()
}
