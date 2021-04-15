//
//  CreateFlowCoordinatorUtility.swift
//  ForwardLeasing
//

import Foundation

// TODO: - Delete file if no time for refatoring

struct CreateFlowCoordinatorUtility {
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
