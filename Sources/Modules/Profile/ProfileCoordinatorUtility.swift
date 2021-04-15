//
//  ProfileCoordinatorUtility.swift
//  ForwardLeasing
//

import Foundation

class ProfileCoordinatorUtility {
  typealias Dependencies = HasUserDataStore
  
  var isLoggedIn: Bool {
    return dependencies.userDataStore.isLoggedIn
  }
  
  private let dependencies: Dependencies

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  // MARK: - Public methods

  func logOut(completion: (() -> Void)? = nil) {
    dependencies.userDataStore.clearAuthData()
    completion?()
  }
}
