//
//  SignedContractViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol SignedContractViewModelDelegate: class {
  func signedContractViewModelDidRequestToCloseScreen(_ viewModel: SignedContractViewModel)
  func signedContractViewModel(_ viewModel: SignedContractViewModel,
                               didRequestToOpenWebViewWithURL url: URL?)
  func signedContractViewModel(_ viewModel: SignedContractViewModel,
                               didRequestToSignDeliveryAgreementFor contract: LeasingEntity)
  func signedContractViewModel(_ viewModel: SignedContractViewModel,
                               didFinishPickUpFor contract: LeasingEntity)
  func signedContractViewModel(_ viewModel: SignedContractViewModel,
                               didFinishSignDeliveryFor contract: LeasingEntity)
  func signedContractViewModel(_ viewModel: SignedContractViewModel,
                               didRequestToSelectOtherStoreWith application: LeasingEntity)
}

class SignedContractViewModel: BindableViewModel {
  typealias Dependencies = HasContractService & HasDeliveryService
  
  weak var delegate: SignedContractViewModelDelegate?
  
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidLoadData: (() -> Void)?
  
  var title: String {
    switch deliveryType {
    case .delivery, .deliveryPartner:
      return R.string.signedContract.deliveryTitleText()
    case .pickup:
      return R.string.signedContract.pickupTitleText(contract?.contractNumber ?? "")
    }
  }
  
  var contractNumber: String? {
    return contract?.contractNumber
  }
  
  var confirmationButtonTitle: String? {
    if deliveryType != .pickup, !isDeliveryActSigned {
      return R.string.signedContract.deliverySignAgreementButtonTitle()
    } else {
      return R.string.common.done()
    }
  }
  
  var deliveryType: DeliveryType {
    return contract?.deliveryType ?? .delivery
  }
  
  var cancelContractAlertTitle: String {
    guard let contractStatus = contract?.status else {
      return R.string.signedContract.cancelApplicationDefaultText()
    }
    
    switch contractStatus {
    case .contractCreated, .contractInit, .signed, .draft:
      return R.string.signedContract.cancelContractAlertTitle()
    case .deliveryCreated, .deliveryStarted:
      return R.string.signedContract.cancelDeliveryAlertTitle()
    default:
      return R.string.signedContract.cancelApplicationDefaultText()
    }
  }
  
  /// Delivery info
  
  var deliveryAddress: String? {
    return contract?.contractActionInfo?.deliveryInfo?.addressString
  }
  
  var deliveryDate: String? {
    var dateComponents = DateComponents()
    dateComponents.day = contract?.contractActionInfo?.deliveryInfo?.daysCount
    guard let date = Calendar.current.date(byAdding: dateComponents, to: Date()) else { return nil }
    return R.string.signedContract.deliveryDateBefore(DateFormatter.dayMonthDisplayable.string(from: date))
  }
  
  var isDeliveryActSigned: Bool {
    return contract?.contractActionInfo?.deliveryInfo?.status?.isSigned ?? false
  }
  
  /// Store info
  
  private (set) var storePointInfo: StorePointInfo?
  
  private var contract: LeasingEntity?
  private var refreshRequest: (() -> Void)?

  private let application: LeasingEntity
  private let dependencies: Dependencies
  
  init(application: LeasingEntity, dependencies: Dependencies,
       storePointInfo: StorePointInfo?) {
    self.application = application
    self.dependencies = dependencies
    self.storePointInfo = storePointInfo
  }

  func refresh() {
    refreshRequest?()
  }

  func loadData() {
    refreshRequest = loadData
    onDidStartRequest?()
    dependencies.contractService.getContract(applicationID: application.applicationID, useCache: false).ensure {
      self.onDidFinishRequest?()
    }.done { response in
      self.contract = response.clientLeasingEntity
      self.onDidLoadData?()
    }.catch { error in
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }
  
  func showContractPDF() {
    let url = URL(string: URLFactory.Cabinet.contractPDF(applicationID: application.applicationID))
    delegate?.signedContractViewModel(self, didRequestToOpenWebViewWithURL: url)
  }
  
  func showAgreementPDF() {
    let url = URL(string: URLFactory.Cabinet.deliveryAgreementPDF(applicationID: application.applicationID))
    delegate?.signedContractViewModel(self, didRequestToOpenWebViewWithURL: url)
  }
  
  func selectOtherStore() {
    delegate?.signedContractViewModel(self, didRequestToSelectOtherStoreWith: application)
  }
  
  func proceed() {
    guard let contract = contract, let deliveryType = contract.deliveryType else { return }

    switch deliveryType {
    case .pickup:
      setStorePoint()
    case .delivery, .deliveryPartner:
      handleDeliveryStatus()
    }
  }

  func cancelContract() {
    guard let contract = contract else { return }
    onDidStartRequest?()
    firstly { () -> Promise<EmptyResponse> in
      switch contract.status {
      case .contractCreated, .contractInit, .signed, .draft:
        return dependencies.contractService.cancelContract(applicationID: application.applicationID)
      case .deliveryCreated, .deliveryStarted:
        return dependencies.deliveryService.cancelDelivery(applicationID: application.applicationID)
      default:
        return Promise.value(EmptyResponse())
      }
    }.ensure {
      self.onDidFinishRequest?()
      self.onDidLoadData?()
    }.done { _ in
      self.delegate?.signedContractViewModelDidRequestToCloseScreen(self)
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }

  func updateStorePoint(_ storePoint: StorePointInfo?) {
    self.storePointInfo = storePoint
    onDidLoadData?()
  }
  
  private func sendOTP() {
    guard let contract = contract else { return }
    onDidStartRequest?()
    firstly { () -> Promise<EmptyResponse> in
      dependencies.deliveryService.signOTP(applicationID: contract.applicationID)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { _ in
      self.delegate?.signedContractViewModel(self,
                                             didRequestToSignDeliveryAgreementFor: contract)
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }

  private func setStorePoint() {
    guard let storePoint = storePointInfo else {
      return
    }
    onDidStartRequest?()
    firstly {
      dependencies.deliveryService.setStore(applicationID: application.applicationID, storePoint: storePoint)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { contract in
      self.onDidLoadData?()
      self.delegate?.signedContractViewModel(self, didFinishPickUpFor: contract)
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }

  private func saveDelivery() {
    guard let contract = contract else {
      return
    }
    refreshRequest = saveDelivery
    onDidStartRequest?()
    firstly {
      dependencies.deliveryService.saveApplicationDelivery(applicationID: contract.applicationID)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { orderStatus in
      self.handleOrderSatus(orderStatus)
    }.catch { error in
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }

  private func handleOrderSatus(_ status: OrderStatus) {
    guard let contract = contract else {
      return
    }
    if status == .none {
      onDidRequestToShowEmptyErrorView?(SelectDeliveryError.productDelivery)
    } else {
      delegate?.signedContractViewModel(self,
                                        didFinishSignDeliveryFor: contract)
    }
  }

  private func handleDeliveryStatus() {
    guard let contract = contract, let status = contract.contractActionInfo?.deliveryInfo?.status else {
      return
    }
    switch status {
    case .new, .created:
      sendOTP()
    case .signSmsSend:
      delegate?.signedContractViewModel(self, didRequestToSignDeliveryAgreementFor: contract)
    case .reserved, .signed:
      saveDelivery()
    default:
      delegate?.signedContractViewModelDidRequestToCloseScreen(self)
    }
  }

}
