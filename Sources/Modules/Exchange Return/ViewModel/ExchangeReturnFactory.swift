//
//  ExchangeReturnFactory.swift
//  ForwardLeasing
//

import Foundation

class ExchangeReturnFactory {
  static func makeCompleteTitleViewModel(title: String) -> TableSectionViewModel {
    let viewModel = ExchangeReturnTitleViewModel(title: title)
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }
  
  static func makeNewLeasingContractSectionViewModel(delegate: NewLeasingContractPDFViewModelDelegate) -> TableSectionViewModel {
    let viewModel = NewLeasingContractPDFViewModel()
    viewModel.delegate = delegate
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }
  
  static func makeBarcodeSectionViewModel(contractNumber: String,
                                          exchangeInfoState: ExchangeReturnState,
                                          barcodeTitles: ExchangeReturnBarcodeTitles) -> TableSectionViewModel {
    let title = barcodeTitles.title(with: exchangeInfoState)
    let header = barcodeTitles.header(with: exchangeInfoState)
    let description = barcodeTitles.description(with: exchangeInfoState)
    let viewModel = ExchangeReturnBarcodeViewModel(contractNumber: contractNumber,
                                             title: title,
                                             contentStrings: [header,
                                                              description],
                                             additionalInfo: [])
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }
  
  static func makeExchangePriceSectionViewModel(earlyExchangePayment: Decimal?,
                                                totalPayment: Decimal?,
                                                priceViewModelTitles: ExchangeReturnPriceTitles) -> TableSectionViewModel {
    let viewModel = ExchangeReturnPriceViewModel(earlyExchangePayment: earlyExchangePayment,
                                           totalPayment: totalPayment,
                                           priceViewModelTitles: priceViewModelTitles)
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }
  
  static func makeExchangeInfoButtonsSectionViewModel(exchangeInfoState: ExchangeReturnState,
                                                      buttonsTitles: ExchangeReturnButtonsTitles,
                                                      delegate: ExchangeReturnButtonsViewModelDelegate)
  -> TableSectionViewModel {
    let viewModel = ExchangeReturnButtonsViewModel(exchangeInfoState: exchangeInfoState, buttonsTitles: buttonsTitles)
    viewModel.delegate = delegate
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }
  
  static func makeSelectExchangeStoreSectionViewModel(selectStoreTitle: String,
                                                      delegate: ExchangeReturnSelectStoreViewModelDelegate?) -> TableSectionViewModel {
    let viewModel = ExchangeReturnSelectStoreViewModel(title: selectStoreTitle)
    viewModel.delegate = delegate
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }
  
  static func makeStoreInfoSectionViewModel(storePointInfo: StorePointInfo?,
                                            delegate: ExchangeReturnStoreInfoViewModelDelegate?) -> TableSectionViewModel {
    let viewModel = ExchangeReturnStoreInfoViewModel(storePointInfo: storePointInfo)
    viewModel.delegate = delegate
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(viewModel)
    return sectionViewModel
  }
}
