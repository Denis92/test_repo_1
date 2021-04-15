//
//  DocumentsBottomSheetViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol DocumentsBottomSheetViewModelDelegate: class {
  func documentsBottomSheetViewModel(_ viewModel: DocumentsBottomSheetViewModel,
                                     didRequestShowPDFWithURL url: URL)
}

class DocumentsBottomSheetViewModel: BottomSheetListViewModel<ContractDocument> {
  // MARK: - Properties
  weak var delegate: DocumentsBottomSheetViewModelDelegate?
  
  // MARK: - Override
  override func didSelect(item: ContractDocument, at index: Int) {
    guard let url = item.url else { return }
    delegate?.documentsBottomSheetViewModel(self, didRequestShowPDFWithURL: url)
  }
}
