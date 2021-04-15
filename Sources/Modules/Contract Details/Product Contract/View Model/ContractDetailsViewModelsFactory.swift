//
//  ContractDetailsViewModelsFactory.swift
//  ForwardLeasing
//

import UIKit

class ContractDetailsViewModelsFactory {
  // MARK: - Contract details
  static func makePaymentButtonSectionViewModel(contract: LeasingEntity,
                                                delegate: ContractMakePaymentButtonViewModelDelegate?) -> TableSectionViewModel {
    let viewModel = ContractMakePaymentButtonViewModel(contract: contract)
    viewModel.delegate = delegate
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }
  
  static func makeExchangeSectionViewModel(contract: LeasingEntity, models: [ModelInfo],
                                           delegate: ExchangeOptionsViewModelDelegate?) -> TableSectionViewModel {
    let sectionViewModel = TableSectionViewModel()
    guard let upgradePayment = contract.productInfo.upgradePayment,
          let paymentsToFreeUpgrade = contract.contractInfo?.paymentsToFreeUpgrade,
          let monthPay = contract.productInfo.monthPay else {
      return sectionViewModel
    }
    let viewModel = ExchangeOptionsViewModel(earlyExchangeSum: upgradePayment, remainingPayments: paymentsToFreeUpgrade,
                                             currentMonthPrice: monthPay, models: models)
    viewModel.delegate = delegate
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }
  
  static func makeAboutProductSectionViewModel(description: String?) -> TableSectionViewModel {
    let viewModel = AboutProductViewModel(description: description)
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }
  
  static func makeAdditionalInfoViewModel(contract: LeasingEntity,
                                          upgradeLeasingEntity: LeasingEntity?,
                                          delegate: ContractDetailsAdditionalInfoViewModelDelegate) -> TableSectionViewModel {
    let viewModel = ContractDetailsAdditionalInfoViewModel(contract: contract, upgradeLeasingEntity: upgradeLeasingEntity)
    viewModel.delegate = delegate
    let section = TableSectionViewModel()
    section.append(viewModel)
    return section
  }
  
  // MARK: - Delivery Details
  static func makeDeliveryViewModel(dependencies: HasDeliveryService,
                                    contract: LeasingEntity) -> TableSectionViewModel {
    let section = TableSectionViewModel()
    let viewModel = ContractDetailsDeliveryViewModel(dependencies: dependencies,
                                                     leasingEntity: contract,
                                                     shouldShowStatusOfDelivery: contract.status != .signed)
    section.append(viewModel)
    return section
  }
  
  // MARK: - Navigation bar content
  static func makeInfoViewModel(contract: LeasingEntity) -> ContractDetailsInfoViewModel {
    let contractNumber = contract.contractNumber ?? ""
    let productProgressImageViewModel = makeProductProgressImageViewModel(contract: contract)
    var dayOfMonth: String?
    if let nextPaymentDate = contract.contractInfo?.nextPaymentDate {
      dayOfMonth = R.string.contractDetails.beforeDayOfMonth(nextPaymentDate.dayOfMonth)
    }
    let leasingStatus = contract.status
    let statusTitle = leasingStatus.isInBackoffice ? dayOfMonth : contract.statusTitle
    let statusSubtitle = leasingStatus.isInBackoffice ?
    R.string.contractDetails.dateOfMonthPayment() :
      R.string.contractDetails.deliveringStatusSubtitle()
    return ContractDetailsInfoViewModel(contractNumber: R.string.contractDetails.contractNumber(contractNumber),
                                        productProgressImageViewModel: productProgressImageViewModel,
                                        monthPayment: contract.productInfo.monthPay?.priceString(withSymbol: true),
                                        statusTitle: statusTitle,
                                        statusSubtitle: statusSubtitle)
  }
  
  static func makePaymentScheduleSectionViewModel(contract: LeasingEntity,
                                                  delegate: PaymentScheduleViewModelDelegate?) -> TableSectionViewModel {
    let viewModel = PaymentScheduleViewModel(contract: contract)
    viewModel.delegate = delegate
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }
  
  static func makeExchangeApplicationSectionViewModel(contract: LeasingEntity,
                                                      upgradeLeasingEntity: LeasingEntity,
                                                      delegate: ContractExchangeApplicationViewModelDelegate,
                                                      dependencies: HasContractService) -> TableSectionViewModel {
    let applicationViewModel = ContractExchangeApplicationViewModel(contract: contract,
                                                                    upgradeLeasingEntity: upgradeLeasingEntity,
                                                                    dependencies: dependencies)
    let viewModel = ContractAdditionalViewModel(title: R.string.contractDetails.exchangeApplicationTitle(),
                                                hint: R.string.contractDetails.exchangeApplicationHintText(),
                                                applicationViewModel: applicationViewModel,
                                                tableCellIdentifier: ContractExchangeApplicationCell.reuseIdentifier)
    applicationViewModel.delegate = delegate
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }

  static func makeReturnApplicationSectionViewModel(contract: LeasingEntity,
                                                    delegate: ContractReturnApplicationViewModelDelegate) -> TableSectionViewModel {
    let applicationViewModel = ContractReturnApplicationViewModel(contract: contract)
    var hint: String?
    if let date = contract.expirationDate, contract.contractActionInfo?.upgradeReturnPaymentSum == nil {
      let nextDate = date.date(byAddingDays: 1)
      let formatter = DateFormatter.dayMonthYearDocument
      hint = R.string.contractDetails.returnApplicationHintText(formatter.string(from: date),
                                                                formatter.string(from: nextDate))
    }
    let viewModel = ContractAdditionalViewModel(title: R.string.contractDetails.returnApplicationTitle(),
                                                hint: hint,
                                                applicationViewModel: applicationViewModel,
                                                tableCellIdentifier: ContractReturnApplicationCell.reuseIdentifier)
    applicationViewModel.delegate = delegate
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }

  private static func makeProductProgressImageViewModel(contract: LeasingEntity) -> ProductProgressImageViewModel {
    let imageURL: URL? = try? contract.productImage?.asURL()
    let productImageViewModel = ProductImageViewModel(imageURL: imageURL)
    // TODO - insert real product type
    let insets = ContractDetailsProgressImageViewInsets(type: .smartphone)
    return ProductProgressImageViewModel(circleProgressInfo: CircleProgressInfo.make(from: contract),
                                         productImageViewModel: productImageViewModel,
                                         insets: insets)
  }
}
