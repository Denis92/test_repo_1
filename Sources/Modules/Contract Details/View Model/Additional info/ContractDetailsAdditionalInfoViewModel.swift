//
//  ContractDetailsAdditionalInfoViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol ContractDetailsAdditionalInfoViewModelDelegate: class {
  func contractDetailsAdditionalInfoViewModelDidRequestBuyout(_ viewModel: ContractDetailsAdditionalInfoViewModel)
  func contractDetailsAdditionalInfoViewModelDidRequestMakeReturn(_ viewModel: ContractDetailsAdditionalInfoViewModel)
  func contractDetailsAdditionalInfoViewModel(_ viewModel: ContractDetailsAdditionalInfoViewModel,
                                              didRequestOpenURL url: URL)
  func contractDetailsAdditionInfoViewModelDidRequestLayout(_ viewModel: ContractDetailsAdditionalInfoViewModel)
  func contractDetailsAdditionalInfoViewModel(_ viewModel: ContractDetailsAdditionalInfoViewModel,
                                              didRequestShowAlertWithMessage message: String)
}

class ContractDetailsAdditionalInfoViewModel: CommonTableCellViewModel,
                                              ContractDetailsAdditionalInfoViewModelProtocol {
  typealias Strings = R.string.contractDetails
  
  // MARK: - Cell properties
  var cachedHeight: CGFloat?
  
  var tableCellIdentifier: String {
    return ContractDetailsAdditionInfoCell.reuseIdentifier
  }
  
  // MARK: - Properties
  weak var delegate: ContractDetailsAdditionalInfoViewModelDelegate?
  
  var onDidRequestLayout: (() -> Void)?
  var onDidUpdateCellHeight: ((CGFloat) -> Void)?
  
  private var hasPenalty: Bool {
    guard let penalty = contract.contractInfo?.overduePenalty else {
      return false
    }
    return penalty > 0 
  }
  
  private(set) lazy var buyoutViewModel = makeBuyoutViewModel()
  private(set) lazy var returnInfoViewModel = makeReturnInfoViewModel()
  private(set) lazy var warrantyServiceViewModel = makeWarrantyServiceViewModel()
  
  private let contract: LeasingEntity
  private let upgradeLeasingEntity: LeasingEntity?
  
  // MARK: - Init
  init(contract: LeasingEntity, upgradeLeasingEntity: LeasingEntity?) {
    self.contract = contract
    self.upgradeLeasingEntity = upgradeLeasingEntity
    onDidRequestLayout = { [weak self] in
      guard let self = self else { return }
      self.delegate?.contractDetailsAdditionInfoViewModelDidRequestLayout(self)
    }
    onDidUpdateCellHeight = { [weak self] height in
      self?.cachedHeight = height
    }
  }
  
  // MARK: - Private
  private func makeBuyoutViewModel() -> AdditionalInfoDescriptionViewModel {
    let price = contract.contractInfo?.buyoutSum?.priceString() ?? ""
    let description = R.string.contractDetails.buyoutDescription()
    let buttonTitle = R.string.contractDetails.buyoutButtonTitle(price)
    let isEnabled = !hasPenalty && upgradeLeasingEntity?.contractActionInfo?.upgradeReturnPaymentSum == nil
    return AdditionalInfoDescriptionViewModel(description: description,
                                              buttonTitle: buttonTitle,
                                              isEnabled: isEnabled) { [weak self] in
      guard let self = self else { return }
      guard !self.hasPenalty else {
        let message = Strings.hasPenaltyAlertMessage(Strings.buyoutDevice())
        self.showAlert(with: message)
        return
      }
      self.delegate?.contractDetailsAdditionalInfoViewModelDidRequestBuyout(self)
    }
  }
  
  private func makeReturnInfoViewModel() -> AdditionalInfoDescriptionViewModel {
    let description = R.string.contractDetails.returnInfoDescription()
    let buttonTitle = R.string.contractDetails.returnInfoButtonTitle()
    let isEnabled = contract.contractInfo?.upgradeReturnEnabled ?? false
    return AdditionalInfoDescriptionViewModel(description: description,
                                              buttonTitle: buttonTitle,
                                              isEnabled: isEnabled) { [weak self] in
      guard let self = self else { return }
      guard !self.hasPenalty else {
        let message = Strings.hasPenaltyAlertMessage(Strings.returnDevice())
        self.showAlert(with: message)
        return
      }
      self.delegate?.contractDetailsAdditionalInfoViewModelDidRequestMakeReturn(self)
    }
  }
  
  private func showAlert(with message: String) {
    delegate?.contractDetailsAdditionalInfoViewModel(self,
                                                     didRequestShowAlertWithMessage: message)
  }
  
  private func makeWarrantyServiceViewModel() -> WarrantyServiceViewModel {
    return WarrantyServiceViewModel { [weak self] url in
      guard let self = self else { return }
      self.delegate?.contractDetailsAdditionalInfoViewModel(self, didRequestOpenURL: url)
    }
  }
}
