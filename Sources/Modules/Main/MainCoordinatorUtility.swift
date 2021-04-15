//
//  MainCoordinatorUtility.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

private extension Constants {
  static let hadFirstRunAlreadyUserDefaultsKey = "hadFirstRunAlready"
}

protocol MainCoordinatorUtilityDelegate: class {
  func deeplinkService(_ utility: MainCoordinatorUtility, didRequestOpenDeeplink deeplink: DeeplinkType)
  func mainCoordinatorUtility(_ utility: MainCoordinatorUtility,
                              didRequestToShowNewVersionAlertWithMessage message: String?,
                              isCritical: Bool, completion: (() -> Void)?)
  func mainCoordinatorUtility(_ utility: MainCoordinatorUtility,
                              didRequestToShowInformationAlertWithMessage message: String?,
                              isCritical: Bool)
}

class MainCoordinatorUtility {
  typealias Dependencies = HasUserDataStore & HasMapService & HasDeeplinkService & HasConfigurationService
  
  weak var delegate: MainCoordinatorUtilityDelegate?
  
  private let dependencies: Dependencies
  private let userDefaults: UserDefaults
  
  init(dependencies: Dependencies, userDefaults: UserDefaults = .standard) {
    self.dependencies = dependencies
    self.userDefaults = userDefaults
    dependencies.deeplinkService.delegate = self
  }
  
  // MARK: - Public methods
  
  func start() {
    clearDataOnFirstRun()
    updateConfiguration()
  }
  
  // MARK: - Private methods
  
  private func clearDataOnFirstRun() {
    let notFirstRun = userDefaults.bool(forKey: Constants.hadFirstRunAlreadyUserDefaultsKey)
    if !notFirstRun {
      userDefaults.set(true, forKey: Constants.hadFirstRunAlreadyUserDefaultsKey)
      dependencies.userDataStore.clearData()
    }
  }
  
  private func updateConfiguration() {
    firstly {
      dependencies.configurationService.getConfiguration()
    }.done { configuration in
      self.handle(configuration)
    }.cauterize()
  }
  
  private func handle(_ configuration: ConfigurationReponse) {
    dependencies.userDataStore.occupationOptions = configuration.occupationOptions
    dependencies.userDataStore.smsRepeatTimeout = configuration.configInfo.smsRepeatTimeout
    
    let showInformationAlert = { [weak self] in
      guard let infoMessage = configuration.infoMessage, let self = self, !infoMessage.message.isEmptyOrNil else { return }
      self.delegate?.mainCoordinatorUtility(self, didRequestToShowInformationAlertWithMessage: infoMessage.message,
                                            isCritical: infoMessage.isCritical)
    }
    
    if let versionInfo = configuration.versionInfo, versionInfo.hasNewVersion {
      delegate?.mainCoordinatorUtility(self, didRequestToShowNewVersionAlertWithMessage: versionInfo.description,
                                       isCritical: versionInfo.isCritical) {
        showInformationAlert()
      }
    } else {
      showInformationAlert()
    }
  }
}

extension MainCoordinatorUtility: DeeplinkServiceDelegate {
  func deeplinkService(_ service: DeeplinkService, didRequestOpenDeeplink deeplink: DeeplinkType) {
    delegate?.deeplinkService(self, didRequestOpenDeeplink: deeplink)
  }
}
