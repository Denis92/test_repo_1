//
//  UserDataStore.swift
//  ForwardLeasing
//

import Foundation
import KeychainAccess

private extension Constants {
  static let smsRepeatDefaultTimeout: Int = 60
}

class UserDataStore: UserDataStoring {
  private struct KeychainKeys {
    static let accessToken = "accessToken"
    static let phoneNumber = "phoneNumber"
  }

  private struct UserDefaultsKeys {
    static let hasShownApplicationOnboarding = "hasShownApplicationOnboarding"
    static let hasShownExchangeOnboarding = "hasShownExchangeOnboarding"
    static let hasShownReturnOnboarding = "hasShownReturnOnboarding"
    static let userID = "userID"
    static let lastDiagnosticSessionID = "lastDiagnosticSessionID"
    static let occupationOptions = "occupationOptions"
    static let smsRepeatTimeout = "smsRepeatTimeout"
  }

  private static let defaultService = "ru.appkode.forwardleasing"

  private let keychain: Keychain
  private let userDefaults: UserDefaults

  var isLoggedIn: Bool {
    return accessToken != nil
  }

  required init(service: String = defaultService, userDefaults: UserDefaults = UserDefaults.standard) {
    self.keychain = Keychain(service: service)
    self.userDefaults = userDefaults
  }

  // MARK: - Clear Data

  func clearData() {
    try? keychain.removeAll()
  }

  func clearAuthData() {
    try? keychain.remove(KeychainKeys.accessToken)
    try? keychain.remove(KeychainKeys.phoneNumber)
  }

  // MARK: - User Defaults

  var hasShownApplicationOnboarding: Bool {
    get {
      return userDefaults.bool(forKey: keychain.service + UserDefaultsKeys.hasShownApplicationOnboarding)
    }
    set {
      userDefaults.set(newValue, forKey: keychain.service + UserDefaultsKeys.hasShownApplicationOnboarding)
    }
  }
  
  var hasShownExchangeOnboarding: Bool {
    get {
      return userDefaults.bool(forKey: keychain.service + UserDefaultsKeys.hasShownExchangeOnboarding)
    }
    set {
      userDefaults.set(newValue, forKey: keychain.service + UserDefaultsKeys.hasShownExchangeOnboarding)
    }
  }
  
  var hasShownReturnOnboarding: Bool {
    get {
      return userDefaults.bool(forKey: keychain.service + UserDefaultsKeys.hasShownReturnOnboarding)
    }
    set {
      userDefaults.set(newValue, forKey: keychain.service + UserDefaultsKeys.hasShownReturnOnboarding)
    }
  }
  
  var lastDiagnosticSessionID: String? {
    get {
      return userDefaults.string(forKey: keychain.service + UserDefaultsKeys.lastDiagnosticSessionID)
    }
    set {
      userDefaults.setValue(newValue, forKey: keychain.service + UserDefaultsKeys.lastDiagnosticSessionID)
    }
  }

  var userID: String {
    get {
      let userIDValue = userDefaults.string(forKey: keychain.service + UserDefaultsKeys.userID)
      if let userID = userIDValue {
        return userID
      } else {
        let newUserID = UUID().uuidString
        userDefaults.set(newUserID, forKey: keychain.service + UserDefaultsKeys.userID)
        return newUserID
      }
    }
    set {
      userDefaults.set(newValue, forKey: keychain.service + UserDefaultsKeys.userID)
    }
  }
  
  var occupationOptions: [OccupationData] {
    get {
      guard let data = userDefaults.data(forKey: keychain.service + UserDefaultsKeys.occupationOptions) else {
        return OccupationData.makeDefaultOptions()
      }
      return (try? JSONDecoder().decode([OccupationData].self, from: data)) ?? OccupationData.makeDefaultOptions()
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue) else { return }
      userDefaults.set(data, forKey: keychain.service + UserDefaultsKeys.occupationOptions)
    }
  }
  
  var smsRepeatTimeout: Int {
    get {
      return (userDefaults.value(forKey: keychain.service + UserDefaultsKeys.smsRepeatTimeout) as? Int)
        ?? Constants.smsRepeatDefaultTimeout
    }
    set {
      userDefaults.set(newValue, forKey: keychain.service + UserDefaultsKeys.smsRepeatTimeout)
    }
  }
  
  var phoneNumber: String? {
    get {
      var phoneNumber: String?
      do {
        phoneNumber = try keychain.getString(KeychainKeys.phoneNumber)
      } catch let error {
        log.debug("Error while getting value for phone number, error: \(error)")
      }
      return phoneNumber
    }
    set {
      guard let newValue = newValue else {
        return
      }
      do {
        try keychain.set(newValue, key: KeychainKeys.phoneNumber)
      } catch let error {
        log.debug("Error while setting value: \(newValue) for phone number, error: \(error)")
      }
    }
  }

  func markApplicationOnboardingAsShown() {
    hasShownApplicationOnboarding = true
  }
}

// MARK: - Access and refresh tokens

extension UserDataStore: TokenStoring {
  var accessToken: String? {
    get {
      var token: String?
      do {
        token = try keychain.getString(KeychainKeys.accessToken)
      } catch let error {
        log.debug("Error while getting value for access token, error: \(error)")
      }
      return token
    }
    set {
      guard let newValue = newValue else {
        try? keychain.remove(KeychainKeys.accessToken)
        return
      }
      do {
        try keychain.set(newValue, key: KeychainKeys.accessToken)
      } catch let error {
        log.debug("Error while setting value: \(newValue) for access token, error: \(error)")
      }
    }
  }
}
