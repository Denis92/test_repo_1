//
//  RegAddressListViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol AddressListViewModelDelegate: class {
  func addressListViewModel(_ viewModel: AddressListViewModel,
                            didSelectAddress address: String, addressObject: AddressResult)
  func addressListViewModelDidUpdate(_ viewModel: AddressListViewModel)
  func addressListViewModel(_ viewModel: AddressListViewModel,
                            shouldShowApartmentNumber shouldShow: Bool)
}

class AddressListViewModel: CommonTableViewModel, BindableViewModel {
  // MARK: - Types
  typealias Dependencies = HasDictionaryService
  
  // MARK: - Properties
  private(set) var needsResize: Bool = false
  private(set) var shouldShowApartmentNumber: Bool = false {
    didSet {
      delegate?.addressListViewModel(self, shouldShowApartmentNumber: shouldShowApartmentNumber)
    }
  }
  
  weak var delegate: AddressListViewModelDelegate?
  
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidLoadData: (() -> Void)?
  
  private(set) lazy var sectionViewModels: [TableSectionViewModel] = []
  private var addresses: [AddressResult] = []
  private let dependencies: Dependencies
  private var selectedAddress: AddressResult?
  
  // MARK: - Init
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Public
  func updateAddress(_ text: String) {
    updateApartmentNumberVisibility(with: selectedAddress, text: text)
    
    onDidStartRequest?()
    firstly {
      dependencies.dictionaryService.searchAddress(text: text)
    }.done { response in
      self.handleResponse(response.addressResult)
      self.onDidFinishRequest?()
      self.delegate?.addressListViewModelDidUpdate(self)
    }.cauterize()
  }
  
  private func updateApartmentNumberVisibility(with address: AddressResult?,
                                               text: String) {
    if let address = address,
       address.addressString.lowercased() ==
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
      shouldShowApartmentNumber = address.address.flatNum == nil
    } else {
      shouldShowApartmentNumber = false
    }
  }
  
  private func handleResponse(_ response: [AddressResult]) {
    addresses = response
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(contentsOf: makeSectionViewModels())
    needsResize = response.count > 5
    sectionViewModels = [sectionViewModel]
  }
  
  // MARK: - Private
  private func makeSectionViewModels() -> [SuggestionCellViewModel] {
    return addresses.enumerated().map { index, addressResult -> SuggestionCellViewModel in
      SuggestionCellViewModel(title: addressResult.addressString,
                              isFirst: index == 0, isLast: index == addresses.count - 1) { [weak self] in
        guard let self = self else { return }
        self.delegate?.addressListViewModel(self, didSelectAddress: addressResult.addressString,
                                            addressObject: addressResult)
        self.selectedAddress = addressResult
        if addressResult.address.flatNum == nil && addressResult.address.blockNum == nil {
          self.shouldShowApartmentNumber = true
        }
      }
    }
  }
}
