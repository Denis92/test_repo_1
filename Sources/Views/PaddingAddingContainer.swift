//
//  PaddingAddingContainer.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

protocol PaddingAddingContainerViewModel {
  var padding: UIEdgeInsets { get }
}

class PaddingAddingContainer<ContentView: UIView & Configurable>: UIView, Configurable {
  // MARK: - Properties
  
  private let configurableView: ContentView
  private var edgeConstraint: Constraint?
  
  // MARK: - Init
  
  init() {
    configurableView = ContentView()
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ContentView.ViewModel) {
    configurableView.configure(with: viewModel)
    
    if let viewModel = viewModel as? PaddingAddingContainerViewModel {
      edgeConstraint?.update(inset: viewModel.padding)
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(configurableView)
    configurableView.snp.makeConstraints { make in
      self.edgeConstraint = make.edges.equalToSuperview().constraint
    }
  }
}
