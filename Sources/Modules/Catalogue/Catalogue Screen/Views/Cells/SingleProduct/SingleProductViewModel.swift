//
//  SingleProductViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol SingleProductViewModelDelegate: class {
  func singleProductViewModel(_ viewModel: SingleProductViewModel, didSelectProduct product: Product)
}

class SingleProductViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return CommonContainerTableViewCell<SingleProductView>.reuseIdentifier
  }

  var contentInsets: UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 20, bottom: 24, right: 20)
  }

  var onDidUpdate: (() -> Void)?
  
  var title: String? {
    return product.title
  }
  
  var price: String? {
    guard let price = product.price else { return nil }
    return R.string.catalogue.screenSingleProductPrice(price)
  }
  
  var backgroundColor: UIColor? {
    return product.backgroundColorHEX.map { UIColor(hexString: $0) }
  }
  
  var productImageURL: URL? {
    guard let productImageURL = product.productImageURL else { return nil }
    return productImageURL.toURL()
  }

  var isAppliances: Bool {
    return product.type == .appliances
  }

  let imageViewConfiguration: ImageViewConfiguration

  let product: Product

  weak var delegate: SingleProductViewModelDelegate?
  
  init(product: Product) {
    self.product = product
    self.imageViewConfiguration = DefaultImageViewConfiguration(type: product.type)
  }

  func selectTableCell() {
    delegate?.singleProductViewModel(self, didSelectProduct: product)
  }

  func imageInset(for style: SingleProductStyle) -> CGFloat {
    switch product.type {
    case .service where style == .large:
      return 32
    case .service where style == .small:
      return 24
    case .appliances where style == .large:
      return 24
    case .appliances where style == .small:
      return 16
    default:
      return 0
    }
  }
}
