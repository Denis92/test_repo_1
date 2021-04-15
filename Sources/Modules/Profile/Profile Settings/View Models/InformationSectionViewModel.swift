//
//  InformationSectionViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol InformationSectionViewModelDelegate: class {
  func informationSectionViewModelDidRequestAboutApp(_ viewModel: InformationSectionViewModel)
  func informationSectionViewModelDidRequestContactWithUs(_ viewModel: InformationSectionViewModel)
  func informationSectionViewModel(_ viewModel: InformationSectionViewModel,
                                   didRequestDocumentWithURL url: URL)
}

class InformationSectionViewModel: TableSectionViewModel {
  weak var delegate: InformationSectionViewModelDelegate?
  
  override init(headerViewModel: CommonTableHeaderFooterViewModel? = nil,
                footerViewModel: CommonTableHeaderFooterViewModel? = nil) {
    super.init(headerViewModel: headerViewModel, footerViewModel: footerViewModel)
    append(contentsOf: makeCells())
  }
  
  private func makeCells() -> [ProfileSettingsLinkViewModel] {
    let aboutAppLink = ProfileSettingsLinkViewModel(title: R.string.profileSettings.aboutAppTitle()) { [weak self] in
      guard let self = self else { return }
      self.delegate?.informationSectionViewModelDidRequestAboutApp(self)
    }
    let contactWithUs = ProfileSettingsLinkViewModel(title: R.string.profileSettings.contactWithUs()) { [weak self] in
      guard let self = self else { return }
      self.delegate?.informationSectionViewModelDidRequestContactWithUs(self)
    }
    let documentCells = NotAuthorizedDocument.allCases.map { document -> ProfileSettingsLinkViewModel in
      return ProfileSettingsLinkViewModel(title: document.title) { [weak self] in
        guard let self = self, let url = document.url else {
          return
        }
        self.delegate?.informationSectionViewModel(self, didRequestDocumentWithURL: url)
      }
    }
    return [aboutAppLink, contactWithUs] + documentCells
  }
}
