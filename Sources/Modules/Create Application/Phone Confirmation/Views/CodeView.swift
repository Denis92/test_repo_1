//
//  PhoneConfirmCodeView.swift
//  ForwardLeasing
//

import UIKit

protocol CodeViewModelProtocol {
  var count: Int { get }
  var filled: Int { get }
}

class CodeView: UIView, Configurable {
  // MARK: - Outlets
  private let stackView = UIStackView()
  private var elements: [UIView] = []
  
  // MARK: - Properties
  
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
  
  func configure(with viewModel: CodeViewModelProtocol) {
    if elements.count != viewModel.count {
      addElements(count: viewModel.count)
    }
    updateElements(filled: viewModel.filled)
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    addSubview(stackView)
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func addElements(count: Int) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    var elements: [UIView] = []
    for _ in 0 ..< count {
      let view = UIView()
      view.makeRoundedCorners(radius: 8)
      view.snp.makeConstraints { make in
        make.size.equalTo(16)
      }
      elements.append(view)
      view.backgroundColor = .accent
      stackView.addArrangedSubview(view)
    }
    self.elements = elements
  }
  
  private func updateElements(filled: Int) {
    elements.forEach {
      $0.backgroundColor = .shade40
    }
    elements.prefix(filled).forEach {
      $0.backgroundColor = .accent
    }
  }
}
