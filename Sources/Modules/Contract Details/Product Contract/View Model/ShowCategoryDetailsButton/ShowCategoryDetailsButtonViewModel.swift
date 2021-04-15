//
//  ShowCategoryDetailsButtonViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol ShowCategoryDetailsButtonViewModelDelegate: class {
  func showCategoryDetailsButtonViewModelDidRequestShowCategory(_ viewModel: ShowCategoryDetailsButtonViewModel)
}

class ShowCategoryDetailsButtonViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return  CommonContainerTableViewCell<ShowCategoryDetailsButtonView>.reuseIdentifier
  }

  var contentInsets: UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 20, bottom: 24, right: 20)
  }
  
  weak var delegate: ShowCategoryDetailsButtonViewModelDelegate?
  
  var onDidUpdate: (() -> Void)?
  
  let title: String?
  let buttonColor: UIColor?
  
  init(title: String?,
       buttonColor: UIColor? = .accent2) {
    self.title = title
    self.buttonColor = buttonColor
  }
  
  func showCategoryDetails() {
    delegate?.showCategoryDetailsButtonViewModelDidRequestShowCategory(self)
  }

  func selectTableCell() {
    showCategoryDetails()
  }
}
