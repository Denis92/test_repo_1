//
//  ExpandableView.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

class ExpandableView<ContentView: UIView>: UIView where ContentView: Configurable {
  // MARK: - Public properties
  var onNeedsToLayoutSuperview: (() -> Void)?
  
  // MARK: - Private properties
  private let headerView = ExpandableHeaderView()
  private let containerView = UIView()
  private let contentView = ContentView()

  private var isExpanded: Bool
  private var containerViewHeightConstraint: Constraint?
  private var contentViewBottomConstraint: Constraint?
  
  // MARK: - Init
  
  init(isExpanded: Bool = true, withDivider: Bool = true) {
    self.isExpanded = isExpanded
    self.headerView.isDividerHidden = !withDivider
    super.init(frame: .zero)
    setup()
    
    onNeedsToLayoutSuperview = { [weak self] in
      self?.superview?.layoutIfNeeded()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(title: String?, viewModel: ContentView.ViewModel) {
    headerView.configure(withTitle: title)
    contentView.configure(with: viewModel)
  }
  
  // MARK: - Public methods
  
  func setExpandedState(isExpanded: Bool, animated: Bool) {
    self.isExpanded = isExpanded
    updateContentConstraints(animated: animated)
  }
  
  // MARK: - Actions
  
  @objc private func didTapHeaderView() {
    isExpanded.toggle()
    updateContentConstraints(animated: true)
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupHeader()
    setupContainerView()
    setupContentView()
    updateContentConstraints(animated: false)
  }
  
  private func setupHeader() {
    addSubview(headerView)
    headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeaderView)))
    headerView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupContainerView() {
    addSubview(containerView)
    containerView.clipsToBounds = true
    containerView.snp.makeConstraints { make in
      make.top.equalTo(headerView.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
      containerViewHeightConstraint = make.height.equalTo(0).constraint
    }
  }
  
  private func setupContentView() {
    containerView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      contentViewBottomConstraint = make.bottom.equalToSuperview().constraint
    }
  }
  
  // MARK: - Private methods
  
  private func updateContentConstraints(animated: Bool) {
    headerView.updateState(isExpanded: isExpanded, animated: animated)
    
    if isExpanded {
      containerViewHeightConstraint?.deactivate()
      contentViewBottomConstraint?.activate()
    } else {
      containerViewHeightConstraint?.activate()
      contentViewBottomConstraint?.deactivate()
    }
    
    if animated {
      UIView.animate(withDuration: 0.3) {
        self.contentView.alpha = self.isExpanded ? 1 : 0
        self.onNeedsToLayoutSuperview?()
      }
    } else {
      self.contentView.alpha = self.isExpanded ? 1 : 0
      self.onNeedsToLayoutSuperview?()
    }
  }
}
