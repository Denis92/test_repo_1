//
//  SelectDeliveryViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

protocol SelectDeliveryViewModelDelegate: class {
  func selectDeliveryViewModel(_ viewModel: SelectDeliveryViewModel,
                               didFinishWithDelivery paymentURL: URL,
                               leasingEntity: LeasingEntity)
  func selectDeliveryViewModel(_ viewModel: SelectDeliveryViewModel,
                               leasingEntity: LeasingEntity,
                               storePoint: StorePointInfo?)
  func selectDeliveryViewModelDidCancelDelivery(_ viewModel: SelectDeliveryViewModel)
  func selectDeliveryViewModelDidRequestReturnToProfile(_ viewModel: SelectDeliveryViewModel)
  func selectDeliveryViewModel(_ viewModel: SelectDeliveryViewModel,
                               didRequestCheckPaymentWith leasingEntity: LeasingEntity)
}

class SelectDeliveryViewModel {
  // MARK: - Types
  typealias Dependencies = HasApplicationService & HasDictionaryService & HasDeliveryService & HasContractService

  // MARK: - Properties
  var onDidRequestUpdateApartmentNumberField: (() -> Void)?
  var onDidRequestHideAddresses: (() -> Void)?
  var onDidRequestShowAddresses: (() -> Void)?
  var onNeedsResizeSuggestionsList: (() -> Void)?
  var onDidUpdateValidity: (() -> Void)?
  var onDidReceiveError: ((SelectDeliveryError) -> Void)?
  var onDidUpdateDeliveryInfo: (() -> Void)?
  var onDidStartInitialLoadingRequest: (() -> Void)?
  var onDidFinishInitialLoadingRequest: (() -> Void)?
  var onDidStartSaveDeliveryTypeRequest: (() -> Void)?
  var onDidFinishSaveDeliveryTypeRequest: (() -> Void)?
  var onDidStartCancelDeliveryRequest: (() -> Void)?
  var onDidFinishCancelDeliveryRequest: (() -> Void)?
  var onDidUpdateDeliveryType: (() -> Void)?
  var onDidUpdateDeliveryInfoVisibility: (() -> Void)?
  var onDidUpdateButtonValidity: (() -> Void)?
  
  weak var delegate: SelectDeliveryViewModelDelegate?
  
  var selectDeliveryTitle: String {
    guard isGoodAvailable else {
      return R.string.deliveryProduct.selectedGoodIsUnavailableTitle()
    }
    if isOnlyPickup {
      return R.string.deliveryProduct.selectTitleLabelOnlyPickupText()
    } else if isOnlyDelivery {
      return R.string.deliveryProduct.selectTitleLabelOnlyDeliveryText()
    } else {
      return R.string.deliveryProduct.selectTitleLabelText()
    }
  }
  
  var isHiddenApartmentNumberField: Bool {
    return !addressListViewModel.shouldShowApartmentNumber
  }
  
  var selectedDeliveryIndex: Int {
    return selectedDeliveryType.intValue
  }
  
  var isOnlyDelivery: Bool {
    return availableDeliveryTypes.count < 2 && availableDeliveryTypes.map { $0.type }.contains(.delivery)
  }
  
  var isOnlyPickup: Bool {
    return availableDeliveryTypes.count < 2 && availableDeliveryTypes.map { $0.type }.contains(.pickup)
  }
  
  var isBothDeliveryType: Bool {
    return !isOnlyPickup && !isOnlyDelivery && availableDeliveryTypes.count > 1
  }
  
  var segmentedControlTitles: [String] {
    return [
      R.string.deliveryProduct.selectSegmentedControlShipmentTitle(),
      R.string.deliveryProduct.selectSegmentedControlPickupTitle()
    ]
  }
  
  var needsResizeSuggestions: Bool {
    return addressListViewModel.needsResize
  }
  
  var isValidAddress: Bool {
    guard let address = address else {
      return false
    }
    return address.address.isFullAddress
  }
  
  var continueButtonTitle: String {
    guard isGoodAvailable else {
      return R.string.deliveryProduct.continueLaterButtonTitle()
    }
    switch selectedDeliveryType {
    case .delivery, .deliveryPartner:
      return R.string.common.continue()
    case .pickup:
      return R.string.deliveryProduct.selectPickPointButtonTitle()
    }
  }

  var isContinueEnabled: Bool {
    return isValid || selectedDeliveryType == .pickup
  }
  
  let addressListViewModel: AddressListViewModel
  let deliveryInfoViewModel = DeliveryInfoViewModel()
  
  private var shouldHandleApartmentNumber: Bool = false
  private var flatNum: String? {
    didSet {
      address?.address.flatNum = flatNum
    }
  }
  
  private(set) var isValid: Bool = false {
    didSet {
      onDidUpdateValidity?()
    }
  }
  
  private var price: Decimal? {
    guard let price = deliveryInfo?.deliveryCost ?? application.contractActionInfo?.deliveryInfo?.cost else {
      return nil
    }
    return Decimal(price)
  }
  
  private var isGoodAvailable: Bool {
    return deliveryInfo?.status != .goodUnavailable
  }
  private var isDeliveryAvailable: Bool {
    return deliveryInfo?.status != .deliveryUnavailable
  }
  
  private var expectedDate: Date? {
    guard let daysCount = deliveryInfo?.daysCount ?? application.contractActionInfo?.deliveryInfo?.daysCount else {
      return nil
    }
    let calendar = Calendar.current
    let dateComponents = DateComponents(day: daysCount)
    return calendar.date(byAdding: dateComponents, to: Date())
  }
  
  private(set) var isHiddenDeliveryInfo: Bool = false {
    didSet {
      onDidUpdateDeliveryInfoVisibility?()
    }
  }
  private(set) var selectedDeliveryType = DeliveryType.delivery {
    didSet {
      onDidUpdateDeliveryType?()
      onDidUpdateValidity?()
    }
  }
  
  private(set) lazy var addressConfigurators = makeTextEditConfigurators()
  
  private var isHiddenSuggestions: Bool = true {
    didSet {
      isHiddenSuggestions ? onDidRequestHideAddresses?() : onDidRequestShowAddresses?()
    }
  }
  
  private var onDidUpdateAddressValidity: ((Bool) -> Void)?
  
  private var shouldHandleRegistrationAddress: Bool = true
  
  private var onDidUpdateRegisterAddress: ((String) -> Void)?
  
  private var addressString: String
  private var deliveryInfo: ProductDeliveryInfo?
  private let dependencies: Dependencies
  private var availableDeliveryTypes: [ProductDeliveryOption] = [] {
    didSet {
      if availableDeliveryTypes.count == 1 {
        selectedDeliveryType = availableDeliveryTypes.first?.type ?? .delivery
      } else {
        selectedDeliveryType = availableDeliveryTypes.first { $0.isDefault }?.type ?? .delivery
      }
    }
  }
  private var address: AddressResult? {
    didSet {
      isHiddenDeliveryInfo = false
      addressString = address?.addressString ?? ""
      if (address?.address.flatNum.isEmptyOrNil ?? true) {
        address?.address.flatNum = flatNum
      }
    }
  }
  private var application: LeasingEntity {
    didSet {
      guard let addressString = application.contractActionInfo?.deliveryInfo?.addressString,
            let address = application.contractActionInfo?.deliveryInfo?.address else {
        return
      }
      let addressResult = AddressResult(addressString: addressString,
                                        address: address)
      updateRegistrationAddress(addressString,
                                addressObject: addressResult)
      addressListViewModel.updateAddress(addressString)
    }
  }
  
  // MARK: - Init
  init(dependencies: Dependencies, application: LeasingEntity) {
    self.dependencies = dependencies
    self.application = application
    addressString = application.contractActionInfo?.deliveryInfo?.addressString ?? ""
    addressListViewModel = AddressListViewModel(dependencies: dependencies)
    addressListViewModel.delegate = self
    updateDeliveryInfoViewModel(with: .normal)
  }
  
  // MARK: - Public
  func load() {
    self.shouldHandleRegistrationAddress = false
    onDidStartInitialLoadingRequest?()
    firstly {
      when(fulfilled: dependencies.contractService.getContract(applicationID: application.applicationID, useCache: false),
           dependencies.deliveryService.getDeliveryTypes(applicationID: application.applicationID))
    }.then { leasingEntityResponse, deliveryTypes -> Promise<ProductDeliveryInfo?> in
      self.application = leasingEntityResponse.clientLeasingEntity
      self.availableDeliveryTypes = deliveryTypes
      guard let addressString = self.application.contractActionInfo?.deliveryInfo?.addressString,
            let addressObject = self.application.contractActionInfo?.deliveryInfo?.address else {
        return Promise.value(nil)
      }
      return Promise(self.getDeliveryInfo(for: AddressResult(addressString: addressString,
                                                             address: addressObject)))
    }.ensure {
      self.onDidFinishInitialLoadingRequest?()
    }.catch { error in
      self.handle(error: error)
    }
  }
}

// MARK: - Other
extension SelectDeliveryViewModel {
  func beginEditingRegistrationAddress() {
    isHiddenSuggestions = false
  }
  
  func continueWithSelectedDelivery() {
    guard isGoodAvailable else {
      delegate?.selectDeliveryViewModelDidRequestReturnToProfile(self)
      return
    }
    onDidStartSaveDeliveryTypeRequest?()
    firstly {
      dependencies.deliveryService.saveDeliveryType(applicationID: application.applicationID,
                                                    deliveryType: selectedDeliveryType)
    }.ensure {
      self.onDidFinishSaveDeliveryTypeRequest?()
    }.done { response in
      self.finish(response: response)
    }.catch { _ in
      self.onDidReceiveError?(SelectDeliveryError.productDelivery)
    }
  }
  
  func selectDeliveryType(with index: Int) {
    switch index {
    case 0:
      let deliveryTypes = availableDeliveryTypes.map { $0.type }
      if deliveryTypes.contains(.delivery) {
        selectedDeliveryType = .delivery
      } else {
        selectedDeliveryType = .deliveryPartner
      }
    default:
      selectedDeliveryType = .pickup
    }
  }
  
  func cancelContract() {
    onDidStartCancelDeliveryRequest?()
    firstly {
      dependencies.applicationService.cancelContract(applicationID: application.applicationID)
    }.ensure {
      self.onDidFinishCancelDeliveryRequest?()
    }.done { _ in
      self.delegate?.selectDeliveryViewModelDidCancelDelivery(self)
    }.catch { _ in
      self.onDidReceiveError?(SelectDeliveryError.productDelivery)
    }
  }
  
  func handleApartmentBeginEditing() {
    shouldHandleApartmentNumber = true
  }
  
  // MARK: - Private Methods
  private func finish(response: LeasingEntity) {
    self.application = response
    switch selectedDeliveryType {
    case .delivery:
      finishWithDeliveryPayment()
    case .deliveryPartner:
      confirmPayment()
    case .pickup:
      getCategoryCodeAndFinish()
    }
  }
  
  private func finishWithDeliveryPayment() {
    let deliveryStatus = application.contractActionInfo?.deliveryInfo?.status
    switch deliveryStatus {
    case .draft:
      if deliveryInfo?.deliveryCost == 0 {
        delegate?.selectDeliveryViewModel(self, didRequestCheckPaymentWith: application)
      } else {
        pay()
      }
    case .createPayment:
      checkPaymentAndPay()
    default:
      onDidReceiveError?(SelectDeliveryError.productDelivery)
    }
  }
  
  private func pay() {
    firstly {
      dependencies.deliveryService.pay(applicationID: application.applicationID, isCancelPrevious: false)
    }.done { response in
      self.delegate?.selectDeliveryViewModel(self, didFinishWithDelivery: response.paymentURL,
                                             leasingEntity: self.application)
    }.catch { _ in
      self.onDidReceiveError?(SelectDeliveryError.productDelivery)
    }
  }
  
  private func confirmPayment() {
    firstly {
      dependencies.deliveryService.confirmPayment(applicationID: application.applicationID)
    }.done { _ in
      self.delegate?.selectDeliveryViewModel(self, didRequestCheckPaymentWith: self.application)
    }.catch { _ in
      self.onDidReceiveError?(SelectDeliveryError.productDelivery)
    }
  }
  
  private func checkPaymentAndPay() {
    firstly {
      dependencies.deliveryService.checkPayment(applicationID: application.applicationID)
    }.done { checkPaymentResponse in
      self.handle(checkPaymentResponse)
    }.catch { _ in
      self.onDidReceiveError?(SelectDeliveryError.productDelivery)
    }
  }
  
  @discardableResult
  private func getDeliveryInfo(for selectedAddress: AddressResult,
                               shouldBind: Bool = true) -> Guarantee<ProductDeliveryInfo?> {
    guard selectedAddress.address.isFullAddress else {
      return Guarantee.value(nil)
    }
    if shouldBind {
      updateDeliveryInfoViewModel(with: .loading)
    }
    return Guarantee { seal in
      firstly {
        dependencies.deliveryService.getDeliveryInfo(applicationID: application.applicationID,
                                                     addressResult: selectedAddress)
      }.then { response in
        self.handle(response)
      }.ensure {
        self.updateDeliveryInfoViewModel(with: .normal)
      }.done { response in
        seal(response)
      }.catch { error in
        self.handle(error: error)
        seal(nil)
      }
    }
  }
  
  private func getCategoryCodeAndFinish() {
    // TODO get category code request
    var storePoint = application.contractActionInfo?.storePoint
    storePoint?.hasRequiredGood = application.contractActionInfo?.storePoint?.goods?
      .contains(where: { $0.goodCode == application.productInfo.goodCode }) ?? false
    delegate?.selectDeliveryViewModel(self, leasingEntity: application,
                                      storePoint: storePoint)
  }
  
  private func updateRegistrationAddress(_ address: String, addressObject: AddressResult) {
    self.address = addressObject
    isHiddenSuggestions = true
    onDidUpdateRegisterAddress?(address)
    onNeedsResizeSuggestionsList?()
    getDeliveryInfo(for: addressObject)
  }
  
  private func handle(_ response: CheckPaymentResponse) {
    guard let paymentURL = response.paymentURL, let url = URL(string: paymentURL) else {
      onDidReceiveError?(SelectDeliveryError.productDelivery)
      return
    }
    delegate?.selectDeliveryViewModel(self, didFinishWithDelivery: url, leasingEntity: application)
  }
  
  private func handle(_ response: ProductDeliveryInfo) -> Promise<ProductDeliveryInfo> {
    deliveryInfo = response
    updateDeliveryInfoViewModel(with: .normal)
    switch response.status {
    case .ok:
      return Promise.value(response)
    case .goodUnavailable:
      return Promise(error: SelectDeliveryError.goodUnavailable)
    case .deliveryUnavailable:
      updateDeliveryInfoViewModel(with: .error)
      return Promise.value(response)
    }
  }
  
  private func handle(error: Error) {
    if let error = error as? SelectDeliveryError {
      self.onDidReceiveError?(error)
    } else {
      let selectDeliveryError = SelectDeliveryError.productDelivery
      self.onDidReceiveError?(selectDeliveryError)
    }
  }
  
  private func makeTextEditConfigurators() -> [FieldConfigurator<AddressFieldType>] {
    return AddressFieldType.allCases.map {
      let configurator = FieldConfigurator(fieldType: $0, text: initialText(for: $0))
      if configurator.type == .deliveryAddress {
        onDidUpdateRegisterAddress = { [weak self, weak configurator] address in
          self?.shouldHandleRegistrationAddress = false
          configurator?.update(text: address)
        }
        onDidUpdateAddressValidity = { [weak configurator] isValid in
          if !isValid {
            configurator?.handle(error: ValidationError.invalidRegistrationAddress)
          } else {
            configurator?.resetToDefaultState()
          }
        }
        configurator.onDidEndEditing = { [weak self, weak configurator] _ in
          guard let self = self else { return }
          self.isHiddenSuggestions = true
          let isValid = !(self.address == nil && configurator?.text != nil) &&
            self.isValidAddress
          self.isValid = isValid
          self.onDidUpdateAddressValidity?(isValid)
        }
      }

      configurator.onDidEndEditing = { [weak self, weak configurator] _ in
        guard let self = self else { return }
        if configurator?.type == .apartmentNumber, let text = configurator?.text {
          if self.shouldHandleApartmentNumber {
            self.flatNum = text
          }
          self.isValid = self.isValidAddress
          self.onDidUpdateAddressValidity?(self.isValidAddress)
          if let address = self.address {
            self.getDeliveryInfo(for: address)
          }
        }
      }

      configurator.onDidChangeText = { [weak self, unowned configurator] text in
        guard let self = self else { return }
        if configurator.type == .deliveryAddress {
          self.handleAddressTextUpdated(text: text)
          self.shouldHandleRegistrationAddress = true
          let isValid = !(self.address == nil && configurator.text != nil) &&
            self.isValidAddress
          self.isValid = isValid
          self.onDidUpdateAddressValidity?(isValid)
        }
      }
      return configurator
    }
  }
  
  private func initialText(for fieldType: AddressFieldType) -> String? {
    if fieldType == .deliveryAddress {
      return application.contractActionInfo?.deliveryInfo?.addressString
    } else {
      return nil
    }
  }
  
  private func handleAddressTextUpdated(text: String?) {
    if isHiddenSuggestions, shouldHandleRegistrationAddress {
      isHiddenSuggestions = false
    }
    if let address = address, text?.trimmingCharacters(in: .whitespacesAndNewlines) != address.addressString {
      self.address = nil
    }
    addressListViewModel.updateAddress(text ?? "")
  }
  
  private func updateDeliveryInfoViewModel(with state: DeliveryInfoViewState) {
    let postIndex = application.contractActionInfo?.deliveryInfo?.postIndex
    let mobilePhone = application.mobilePhoneMasked
    deliveryInfoViewModel.updateUserDataItems(postIndex: postIndex, mobilePhone: mobilePhone)
    deliveryInfoViewModel.updateDeliveryInfoItems(expectedDate: expectedDate, price: price)
    deliveryInfoViewModel.updateState(state)
    deliveryInfoViewModel.invalidateUpdate()
  }
}

// MARK: - AddressListViewModelDelegate
extension SelectDeliveryViewModel: AddressListViewModelDelegate {
  func addressListViewModel(_ viewModel: AddressListViewModel,
                            shouldShowApartmentNumber shouldShow: Bool) {
    onDidRequestUpdateApartmentNumberField?()
  }
  
  func addressListViewModelDidUpdate(_ viewModel: AddressListViewModel) {
    onNeedsResizeSuggestionsList?()
  }
  
  func addressListViewModel(_ viewModel: AddressListViewModel, didSelectAddress address: String,
                            addressObject: AddressResult) {
    updateRegistrationAddress(address, addressObject: addressObject)
  }
}
