//
//  ProductPairViewModel.swift
//  ForwardLeasing
//

import UIKit.UIView

protocol ProductPairViewModelDelegate: class {
  func productPairViewModel(_ viewModel: ProductPairViewModel, didSelectProduct product: Product)
}

class ProductPairViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return CommonContainerTableViewCell<ProductPairView>.reuseIdentifier
  }
  
  var contentInsets: UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 20, bottom: 24, right: 20)
  }
  
  weak var delegate: ProductPairViewModelDelegate?
  
  private (set) var productViewModels: [SingleProductViewModel] = []
  
  init(productPair: (Product, Product)) {
    let viewModel1 = SingleProductViewModel(product: productPair.0)
    viewModel1.delegate = self
    productViewModels.append(viewModel1)
    
    let viewModel2 = SingleProductViewModel(product: productPair.1)
    viewModel2.delegate = self
    productViewModels.append(viewModel2)
  }
}

extension ProductPairViewModel: SingleProductViewModelDelegate {
  func singleProductViewModel(_ viewModel: SingleProductViewModel, didSelectProduct product: Product) {
    delegate?.productPairViewModel(self, didSelectProduct: product)
  }
}
