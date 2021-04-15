//
//  CurrentApplicationsViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol CurrentApplicationsViewModelDelegate: class {
  func currentApplicationsViewModel(_ viewModel: CurrentApplicationsViewModel,
                                    didRequestToContinueWith application: LeasingEntity)
  func currentApplicationsViewModel(_ viewModel: CurrentApplicationsViewModel,
                                    didRequestToFinishWith application: LeasingEntity)
  func currentApplicationsViewModel(_ viewModel: CurrentApplicationsViewModel,
                                    didRequestToContinueOTPFlowWith application: LeasingEntity)
  func currentApplicationsViewModelDidEncounterCriticalError(_ viewModel: CurrentApplicationsViewModel)
}

private enum FailableRequestType {
  case cancelApplications, createApplication, updateClientData
}

class CurrentApplicationsViewModel: CommonTableViewModel, BindableViewModel {
  typealias Dependencies = HasApplicationService & HasPersonalDataRegisterService
  
  // MARK: - Properties
  
  weak var delegate: CurrentApplicationsViewModelDelegate?
  
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidRequestDeleteRow: ((IndexPath) -> Void)?
  var onDidLoadData: (() -> Void)?
  
  var sectionViewModels: [TableSectionViewModel] {
    let section = TableSectionViewModel(headerViewModel: CurrentApplicationsTableHeaderViewModel(isUpgrade: isUpgrade),
                                        footerViewModel: nil)
    section.append(contentsOf: applicationsAndProducts.map { productInfo, application in
      let viewModel = CurrentApplicationsItemViewModel(applicationProduct: productInfo,
                                                       application: application,
                                                       isUpgrade: isUpgrade)
      viewModel.delegate = self
      return viewModel
    })
    return [section]
  }
  
  private let flow: CurrentApplicationsFlow
  private let isUpgrade: Bool
  private let dependencies: Dependencies

  private var applicationCreationInfo: ApplicationCreationInfo?
  private var currentSelectedApplication: LeasingEntity?
  private var failedRequestType: FailableRequestType?
  private var activeApplicationData: (LeasingEntity, ClientPersonalData)?
  private var requestCancellationCompletion: (() -> Void)?
  
  private var applicationsAndProducts: [(LeasingProductInfo, LeasingEntity?)] = []
  
  // MARK: - Init
  
  init(flow: CurrentApplicationsFlow, isUpgrade: Bool, dependencies: Dependencies) {
    self.flow = flow
    self.isUpgrade = isUpgrade
    self.dependencies = dependencies
    switch flow {
    case .hasCurrentApplication(let applications):
      applicationsAndProducts = applications.map { ($0.productInfo, $0) }
    case .hasNoCurrentApplication(let applications, let applicationCreationInfo):
      self.applicationCreationInfo = applicationCreationInfo
      applicationsAndProducts = []
      if let product = applicationCreationInfo.product, !isUpgrade {
        applicationsAndProducts.append((product, nil))
      }
      applicationsAndProducts.append(contentsOf: applications.map { ($0.productInfo, $0) })
    case .updateClientData(let applications, let activeApplicationData):
      self.activeApplicationData = activeApplicationData
      applicationsAndProducts = applications.map { ($0.productInfo, $0) }
    }
  }

  // MARK: - Public methods

  func repeatFailedRequest() {
    guard let type = failedRequestType else {
      return
    }

    switch type {
    case .cancelApplications:
      cancelNonSelectedApplications()
    case .createApplication:
      createNewApplication()
    case .updateClientData:
      updateClientData()
    }
  }
  
  // MARK: - Private methods

  private func cancelNonSelectedApplications() {
    cancelApplications(except: currentSelectedApplication)
  }
  
  private func cancelApplications(except application: LeasingEntity?) {
    failedRequestType = nil
    let applicationsToCancel = applicationsAndProducts.compactMap { $0.1 }.filter { $0 != application }
    let promises = applicationsToCancel.map { cancelLeasingEntity(leasingEntity: $0) }
    onDidStartRequest?()
    when(fulfilled: promises).ensure {
      self.onDidFinishRequest?()
    }.then { _ -> Promise<Void> in
      guard let application = application else { return Promise() }
      return self.updateApplicationData(with: application)
    }.done { _ in
      self.requestCancellationCompletion?()
    }.catch { error in
      self.failedRequestType = .cancelApplications
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }

  private func cancel(_ leasingEntity: LeasingEntity) {
    onDidStartRequest?()
    firstly {
      cancelLeasingEntity(leasingEntity: leasingEntity)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { _ in
      self.updateApplicationsAndProducts(with: leasingEntity)
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }

  private func updateApplicationsAndProducts(with cancelledLeasingEntity: LeasingEntity) {
    guard let index = applicationsAndProducts.map({ $0.1 }).firstIndex(where: { $0?.applicationID == cancelledLeasingEntity.applicationID }) else {
      return
    }
    applicationsAndProducts.remove(at: index)
    if applicationsAndProducts.isEmpty {
      onDidRequestDeleteRow?(IndexPath(item: index, section: 0))
    } else {
      continueExchange()
    }
  }

  private func continueExchange() {
    switch (applicationCreationInfo, activeApplicationData) {
    case (_, nil):
      createNewApplication()
    case (nil, _):
      updateClientData()
    default:
      break
    }
  }

  private func updateApplicationData(with application: LeasingEntity) -> Promise<Void> {
    return firstly {
      self.dependencies.applicationService.getApplicationData(applicationID: application.applicationID)
    }.then { application -> Promise<Void> in
      self.currentSelectedApplication = application
      return Promise()
    }
  }

  private func cancelLeasingEntity(leasingEntity: LeasingEntity) -> Promise<EmptyResponse> {
    if leasingEntity.isContract {
      return dependencies.applicationService.cancelContract(applicationID: leasingEntity.applicationID)
    } else {
      return dependencies.applicationService.cancelApplication(applicationID: leasingEntity.applicationID)
    }
  }

  private func createNewApplication() {
    guard let phone = applicationCreationInfo?.phone, let email = applicationCreationInfo?.email,
          let basketID = applicationCreationInfo?.basketID, let type = applicationCreationInfo?.leasingType else {
      delegate?.currentApplicationsViewModelDidEncounterCriticalError(self)
      return
    }
    failedRequestType = nil

    onDidStartRequest?()

    firstly {
      dependencies.personalDataRegistrationService.createLeasingApplication(basketID: basketID,
                                                                            type: type,
                                                                            email: email,
                                                                            phone: phone,
                                                                            previousApplicationID: applicationCreationInfo?.previousApplicationID)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { application in
      self.delegate?.currentApplicationsViewModel(self, didRequestToContinueOTPFlowWith: application)
    }.catch { error in
      if (error as? CustomServerError)?.errorType == .basketInvalid {
        self.onDidRequestToShowErrorBanner?(error)
        self.delegate?.currentApplicationsViewModelDidEncounterCriticalError(self)
      } else {
        self.failedRequestType = .createApplication
        self.onDidRequestToShowEmptyErrorView?(error)
      }
    }
  }

  private func updateClientData() {
    guard let applicationData = activeApplicationData else {
      delegate?.currentApplicationsViewModelDidEncounterCriticalError(self)
      return
    }
    failedRequestType = nil

    onDidStartRequest?()

    firstly {
      dependencies.applicationService.saveClientData(data: applicationData.1, applicationID: applicationData.0.applicationID)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { _ in
      self.delegate?.currentApplicationsViewModel(self, didRequestToFinishWith: applicationData.0)
    }.catch { error in
      self.failedRequestType = .updateClientData
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }
}

// MARK: - CurrentApplicationsItemViewModelDelegate

extension CurrentApplicationsViewModel: CurrentApplicationsItemViewModelDelegate {
  func currentApplicationsItemViewModelDidRequestCreateNewApplication(_ viewModel: CurrentApplicationsItemViewModel) {
    requestCancellationCompletion = { [weak self] in
      self?.createNewApplication()
    }
    cancelNonSelectedApplications()
  }

  func currentApplicationsItemViewModel(_ viewModel: CurrentApplicationsItemViewModel,
                                        didRequestToContinueWith application: LeasingEntity) {
    currentSelectedApplication = application
    requestCancellationCompletion = { [weak self] in
      guard let self = self, let selectedApplication = self.currentSelectedApplication else {
        return
      }
      if self.activeApplicationData?.0.applicationID == selectedApplication.applicationID {
        self.updateClientData()
      } else {
        self.delegate?.currentApplicationsViewModel(self, didRequestToContinueWith: selectedApplication)
      }
    }
    cancelNonSelectedApplications()
  }

  func currentApplicationsItemViewModel(_ viewModel: CurrentApplicationsItemViewModel,
                                        didRequestToCancel application: LeasingEntity) {
    cancel(application)
  }
}
