//
//  TextInputSuggestionsContaining.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

protocol TextInputSuggestionsContaining where Self: UIViewController {
  typealias ViewModel = CommonTableViewModel & BindableViewModel
  
  var suggestionsListView: SuggestionListView? { get set }
  var contentView: UIView { get }
  var needsResizeSuggestions: Bool { get }
  var suggestionsListBottomConstraintItem: ConstraintItem? { get set }
  
  func handleSuggestionsResize()
  func showSuggestions(with viewModel: ViewModel)
  func hideAddressList()
}

extension TextInputSuggestionsContaining where Self: UIViewController & TextInputContaining {
  func handleSuggestionsResize() {
    remakeBottomSuggestionListConstraint()
    updateBottomInset()
  }
  
  func showSuggestions(with viewModel: ViewModel) {
    self.suggestionsListView?.removeFromSuperview()
    
    let suggestionsListView = SuggestionListView(viewModel: viewModel)
    contentView.addSubview(suggestionsListView)
    
    suggestionsListView.snp.makeConstraints { make in
      makeAddressListSizeConstraints(make: make)
    }
    
    suggestionsListView.layer.shadowOpacity = 0.12
    suggestionsListView.layer.shadowOffset = CGSize(width: 0.0, height: 2)
    suggestionsListView.layer.shadowRadius = 4
    suggestionsListView.layer.shadowColor = UIColor.black.cgColor
    self.suggestionsListView = suggestionsListView
  }
  
  func hideAddressList() {
    self.suggestionsListView?.removeFromSuperview()
  }
  
  private func remakeBottomSuggestionListConstraint() {
    guard suggestionsListView?.superview != nil else { return }
    suggestionsListView?.snp.remakeConstraints { make in
      makeAddressListSizeConstraints(make: make)
    }
  }
  
  private func makeAddressListSizeConstraints(make: ConstraintMaker) {
    guard let suggestionsListBottomConstraintItem = suggestionsListBottomConstraintItem else {
      return
    }
    make.leading.trailing.equalToSuperview().inset(16)
    make.top.equalTo(suggestionsListBottomConstraintItem).offset(1)
    if needsResizeSuggestions {
      make.bottom.equalToSuperview()
    } else {
      make.height.greaterThanOrEqualTo(56)
    }
  }
}
