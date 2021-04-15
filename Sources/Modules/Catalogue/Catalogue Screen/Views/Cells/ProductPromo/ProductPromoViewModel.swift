//
//  ProductPromoViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol ProductPromoViewModelDelegate: class {
  func productPromoViewModel(_ viewModel: ProductPromoViewModel, didSelectPromo promo: Promo)
}

class ProductPromoViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return CommonContainerTableViewCell<ProductPromoView>.reuseIdentifier
  }

  var contentInsets: UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 20, bottom: 24, right: 20)
  }

  var onDidUpdate: (() -> Void)?
  
  let backgroundImageURL: URL?
  let foregroundImageURL: URL?
  let topLeft: String?
  let topRight: String?
  let centerLeft: String?
  let centerRight: String?
  let bottomLeft: String?
  let bottomRight: String?
  let imageViewConfiguration: ImageViewConfiguration

  weak var delegate: ProductPromoViewModelDelegate?

  private let promo: Promo

  init(backgroundImage: String,
       foregroundImage: String,
       topLeft: String?,
       topRight: String?,
       centerLeft: String?,
       centerRight: String?,
       bottomLeft: String?,
       bottomRight: String?,
       promo: Promo) {
    self.backgroundImageURL = backgroundImage.toURL()
    self.foregroundImageURL = foregroundImage.toURL()
    self.topLeft = topLeft
    self.topRight = topRight
    self.centerLeft = centerLeft
    self.centerRight = centerRight
    self.bottomLeft = bottomLeft
    self.bottomRight = bottomRight
    self.promo = promo
    self.imageViewConfiguration = DefaultImageViewConfiguration(type: promo.type)
  }

  func selectTableCell() {
    delegate?.productPromoViewModel(self, didSelectPromo: promo)
  }
}
