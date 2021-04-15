//
//  ProfileSettingsViewModelFactory.swift
//  ForwardLeasing
//

import UIKit

struct ProfileSettingsViewModelFactory {
  // Credit cards
  func makeCreditCardsSection(from cards: [Card], delegate: CreditCardsSectionViewModelDelegate) -> CreditCardsSectionViewModel? {
    guard !cards.isEmpty else { return nil }
    let viewModel = CreditCardsSectionViewModel(cards: cards)
    viewModel.delegate = delegate
    return viewModel
  }
  
  // Access
  func makeAccessSection(topOffset: CGFloat = 32,
                         onDidTapUpdatePinCode: (() -> Void)?) -> TableSectionViewModel {
    let headerViewModel = TitleHeaderViewModel(title: R.string.profileSettings.accessTitle(),
                                               topOffset: topOffset)
    let section = TableSectionViewModel(headerViewModel: headerViewModel)
    let updatePinCodeLinkViewModel = ProfileSettingsLinkViewModel(title: R.string.profileSettings.updatePinCodeText(),
                                                                  onDidSelect: onDidTapUpdatePinCode)
    section.append(updatePinCodeLinkViewModel)
    return section
  }
  
  // Information
  func makeInformationSection(delegate: InformationSectionViewModelDelegate,
                              withHeader: Bool = true) -> InformationSectionViewModel {
    var headerViewModel: TitleHeaderViewModel?
    if withHeader {
      headerViewModel = TitleHeaderViewModel(title: R.string.profileSettings.informationSectionTilte(),
                                             topOffset: 32)
    }
    let section = InformationSectionViewModel(headerViewModel: headerViewModel)
    section.delegate = delegate
    return section
  }
}
