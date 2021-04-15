//
//  CreateApplicationCoordinatorUtility.swift
//  ForwardLeasing
//

import Foundation

struct CreateApplicationCoordinatorUtility {
  typealias Dependencies = HasUserDataStore

  var needsToShowOnboarding: Bool {
    return !dependencies.userDataStore.hasShownApplicationOnboarding
  }

  private let dependencies: Dependencies

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  func markOnboardingAsShown() {
    dependencies.userDataStore.markApplicationOnboardingAsShown()
  }
}
