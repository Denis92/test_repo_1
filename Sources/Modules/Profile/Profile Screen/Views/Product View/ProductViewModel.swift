//
//  ProductViewModel.swift
//  ForwardLeasing
//

import Foundation

class ProductViewModel: ProductViewModelProtocol, CommonTableCellViewModel {
  // MARK: - Properties
  var tableCellIdentifier: String {
    return ProductCell.reuseIdentifier
  }

  var itemsViewModels: [StackViewItemViewModel] = []

  private let leasingEntity: LeasingEntity
  
  weak var delegate: ProfileCellViewModelsDelegate?

  // MARK: - Init
  init(leasingEntity: LeasingEntity,
       infoViewModel: ProductInfoViewModel,
       deliveryViewModel: ProductDeliveryViewModel?,
       statusDescriptionViewModel: ProductStatusDescriptionViewModel?,
       buttonsViewModel: ProductButtonsViewModel) {
    self.leasingEntity = leasingEntity
    itemsViewModels.append(infoViewModel)
    if let deliveryViewModel = deliveryViewModel {
      itemsViewModels.append(deliveryViewModel)
    }
    if let statusDescriptionViewModel = statusDescriptionViewModel {
      itemsViewModels.append(statusDescriptionViewModel)
    }
    buttonsViewModel.delegate = self
    itemsViewModels.append(buttonsViewModel)
  }

  func selectTableCell() {
    delegate?.cellViewModel(self, didSelect: .selectLeasingEntity(leasingEntity))
  }
}

// MARK: - ProductButtonsViewModelDelegate
extension ProductViewModel: ProductButtonsViewModelDelegate {
  func productButtonsViewModel(_ productButtonsViewModel: ProductButtonsViewModel,
                               didSelectAction action: ProductButtonAction) {
    delegate?.cellViewModel(self, didSelect: .leasingEntityAction(action, leasingEntity))
  }
}
