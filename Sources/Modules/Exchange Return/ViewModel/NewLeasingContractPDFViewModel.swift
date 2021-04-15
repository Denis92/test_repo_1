//
//  NewLeasingContractPDFViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol NewLeasingContractPDFViewModelDelegate: class {
  func newLeasingContractPDFViewModelDidRequestToShowPDF(_ viewModel: NewLeasingContractPDFViewModel)
}

class NewLeasingContractPDFViewModel: DocumentPDFViewModelProtocol {
  weak var delegate: NewLeasingContractPDFViewModelDelegate?
  
  let type: DocumentPDFViewType = .newLeasingContract
  let signingState: DocumentPDFViewSigningState
  
  init(signingState: DocumentPDFViewSigningState = .signed) {
    self.signingState = signingState
  }
  
  func didTapButton() {
    delegate?.newLeasingContractPDFViewModelDidRequestToShowPDF(self)
  }
}

// MARK: - CommonTableCellViewModel

extension NewLeasingContractPDFViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ExchangeReturnDocumentCell.reuseIdentifier
  }
}

// MARK: - PaddingAddingContainerViewModel

extension NewLeasingContractPDFViewModel: PaddingAddingContainerViewModel {
  var padding: UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 20, bottom: 32, right: 20)
  }
}
