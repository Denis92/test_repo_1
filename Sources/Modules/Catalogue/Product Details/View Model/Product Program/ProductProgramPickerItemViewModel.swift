//
//  ProductProgramPickerItemViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol ProductProgramPickerItemViewModelDelegate: class {
  func productProgramPickerItemViewModel(_ viewModel: ProductProgramPickerItemViewModel,
                                         didSetStateOf service: ProductAdditionalService,
                                         isSelected: Bool)
}

class ProductProgramPickerItemViewModel {
  // MARK: - Properties
  
  weak var delegate: ProductProgramPickerItemViewModelDelegate?
  var onDidUpdate: (() -> Void)?
  
  var title: String? {
    return service.name
  }
  
  let infoURL: URL?
  private(set) var isSelected = false
  private let service: ProductAdditionalService
  
  // MARK: - Init
  
  init(service: ProductAdditionalService) {
    self.service = service
    // TODO: - Replace with actual url
    self.infoURL = URL(string: "https://google.com")
  }
  
  // MARK: - Public methods
  
  func didTapView() {
    isSelected.toggle()
    onDidUpdate?()
    delegate?.productProgramPickerItemViewModel(self, didSetStateOf: service,
                                                isSelected: isSelected)
  }
}
