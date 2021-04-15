//
//  WarrantyServiceView.swift
//  ForwardLeasing
//

import UIKit

protocol WarrantyServiceViewModelProtocol {
  var text: NSAttributedString { get }
  var onDidSelectURL: ((URL) -> Void)? { get }
}

class WarrantyServiceView: UIView, Configurable {
  // MARK: - Outlets
  private let textView = UITextView()
  
  // MARK: - Properties
  private var onDidSelectURL: ((URL) -> Void)?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Public Methods
  
  func configure(with viewModel: WarrantyServiceViewModelProtocol) {
    textView.attributedText = viewModel.text
    onDidSelectURL = viewModel.onDidSelectURL
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    addSubview(textView)
    textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.accent]
    textView.isScrollEnabled = false
    textView.sizeToFit()
    textView.delegate = self
    textView.showsHorizontalScrollIndicator = false
    textView.isEditable = false
    textView.isSelectable = true
    textView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(4)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().offset(-4)
    }
  }
}

// MARK: - UITextViewDelegate
extension WarrantyServiceView: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                in characterRange: NSRange,
                interaction: UITextItemInteraction) -> Bool {
    onDidSelectURL?(URL)
    return false
  }
}
