//
//  ContractSigningViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol ContractSigningViewModelDelegate: class {
  func contractSigningViewModel(_ viewModel: ContractSigningViewModel, didRequestToOpen url: URL)
  func contractSigningViewModel(_ viewModel: ContractSigningViewModel, didRequestToSignWithSMS leasingEntity: LeasingEntity)
}

class ContractSigningViewModel: BindableViewModel {
  typealias Dependencies = HasContractService
  
  // MARK: - Properties
  
  weak var delegate: ContractSigningViewModelDelegate?
  
  var totalPriceTitle: String? {
    guard let monthsCount = contract?.productInfo.paymentsCount else { return nil }
    return R.string.contractSigning.contractTotoalPriceTitle(R.string.plurals.months(count: monthsCount))
  }
  
  var totalPrice: String? {
    return totalPaymentSum.priceString()
  }
  
  var onDidUpdate: (() -> Void)?
  var onDidStartRequest: (() -> Void)?
  var onDidStartSmsSendingRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidLoadData: (() -> Void)?
  
  let agreementViewModel: AgreementCheckboxViewModelProtocol
  
  private(set) var contractFeatureViewModels: [ContractSigningFeatureViewModel] = []
  private(set) var infoItemViewModels: [ContractInfoItemViewModel] = []
  private(set) var canSignContract: Bool = false
  
  private var contract: LeasingEntity?
  private var totalPaymentSum: Decimal {
    guard let monthsCount = contract?.productInfo.paymentsCount,
          let payment = contract?.productInfo.monthPay else { return 0 }
    return Decimal(monthsCount) * payment
  }
  
  private let application: LeasingEntity
  private let dependencies: Dependencies
  
  // MARK: - Init
  
  init(application: LeasingEntity, dependencies: Dependencies) {
    self.application = application
    self.dependencies = dependencies
    self.agreementViewModel = ContractSigningAgreementViewModel(applicationID: application.applicationID)
    bindAgreementViewModel()
  }
  
  // MARK: - Public methods
  
  func loadData() {
    onDidStartRequest?()
    dependencies.contractService.getContract(applicationID: application.applicationID, useCache: false).ensure {
      self.onDidFinishRequest?()
    }.done { response in
      self.contract = response.clientLeasingEntity
      self.makeContractFeatures()
      self.makeInfoItemViewModels()
      self.onDidLoadData?()
    }.catch { error in
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }
  
  func openContractPDF() {
    guard let url = URL(string: URLFactory.Cabinet.contractPDF(applicationID: application.applicationID)) else { return }
    delegate?.contractSigningViewModel(self, didRequestToOpen: url)
  }
  
  func proceed() {
    guard let contractID = contract?.applicationID else { return }
    
    onDidStartSmsSendingRequest?()
    firstly { () -> Promise<LeasingEntityResponse> in
      dependencies.contractService.getContract(applicationID: contractID, useCache: false)
    }.then { contract -> Promise<EmptyResponse> in
      if contract.clientLeasingEntity.status == .contractInit {
        return self.dependencies.contractService.sendContractCode(applicationID: self.application.applicationID)
      } else {
        return self.dependencies.contractService.resendContractSmsCode(applicationID: self.application.applicationID)
      }
    }.ensure {
      self.onDidFinishRequest?()
    }.done { _ in
      guard let contract = self.contract else {
        return
      }
      self.delegate?.contractSigningViewModel(self, didRequestToSignWithSMS: contract)
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }
  
  // MARK: - Private methods
  
  private func bindAgreementViewModel() {
    self.agreementViewModel.onDidSelectURL = { [weak self] url in
      guard let self = self else { return }
      self.delegate?.contractSigningViewModel(self, didRequestToOpen: url)
    }
    self.agreementViewModel.onDidToggleCheckbox = { [weak self] isSelected in
      self?.canSignContract = isSelected
      self?.onDidUpdate?()
    }
  }
  
  private func makeInfoItemViewModels() {
    infoItemViewModels.removeAll()
    if let monthlyPayment = contract?.productInfo.monthPay {
      infoItemViewModels.append(ContractInfoItemViewModel(type: .monthlyPayment(payment: monthlyPayment)))
    }
    if let paymentsCount = contract?.productInfo.paymentsCount {
      infoItemViewModels.append(ContractInfoItemViewModel(type: .monthsCount(count: paymentsCount)))
    }
    if let earlyExchangeSum = contract?.productInfo.upgradePayment,
       let earlyExchangeMonthsCount = contract?.productInfo.earlyUpgradePaymentsCount {
      infoItemViewModels.append(ContractInfoItemViewModel(type: .earlyExchange(price: earlyExchangeSum,
                                                                               paymentsCount: earlyExchangeMonthsCount)))
    }
    if let freeExchangeMonthsCount = contract?.productInfo.freeUpgradePaymentsCount {
      infoItemViewModels.append(ContractInfoItemViewModel(type: .freeExchange(paymentsCount: freeExchangeMonthsCount)))
    }
    if let residualSum = contract?.productInfo.residualValue {
      infoItemViewModels.append(ContractInfoItemViewModel(type: .residualSum(sum: residualSum)))
    }
    infoItemViewModels.append(ContractInfoItemViewModel(type: .earlyRedemption))
    if let leasingServicePrice = contract?.productInfo.leasingServicePrice, leasingServicePrice != 0 {
      infoItemViewModels.append(ContractInfoItemViewModel(type: .residualSum(sum: leasingServicePrice)))
    } else {
      infoItemViewModels.append(ContractInfoItemViewModel(type: .noOverpayment))
    }
  }
  
  private func makeContractFeatures() {
    contractFeatureViewModels.removeAll()
    let productPrice = totalPaymentSum - (contract?.additionalServicesInfo ?? []).reduce(0) { $0 + $1.price }
    contractFeatureViewModels.append(ContractSigningFeatureViewModel(title: contract?.productInfo.goodName,
                                                                     value: productPrice.priceString()))
    if let programName = contract?.additionalServicesInfo.element(at: 0)?.name,
       let programPrice = contract?.additionalServicesInfo.element(at: 0)?.price {
      contractFeatureViewModels.append(ContractSigningFeatureViewModel(title: programName, value: programPrice.priceString()))
    }
  }
}
