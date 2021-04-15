//
//  BaseActionSheetViewController.swift
//  ForwardLeasing
//

import UIKit

class BaseActionSheetViewController: BottomSheetViewController {
  override var backgroundColor: UIColor {
    .clear
  }
  
  private var withCloseButton: Bool
  
  private let containerView = UIView()
  private let closeButton = UIButton(type: .system)
  
  // MARK: - Init
  
  init(withCloseButton: Bool) {
    self.withCloseButton = withCloseButton
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  // MARK: - Public methods
  
  func addSubview(_ view: UIView) {
    containerView.addSubview(view)
  }
  
  // MARK: - Actions
  
  @objc private func handleCloseButtonTapped() {
    removeBottomSheetViewController(animated: true)
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainerView()
    
    if withCloseButton {
      setupCloseButton()
    }
  }
  
  private func setupContainerView() {
    view.addSubview(containerView)
    
    containerView.backgroundColor = .base2
    containerView.layer.cornerRadius = 30
    
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().inset(42)
    }
  }
  
  private func setupCloseButton() {
    containerView.addSubview(closeButton)
    
    closeButton.setImage(R.image.bottomSheetCloseIcon(), for: .normal)
    closeButton.tintColor = .shade60
    closeButton.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
    
    closeButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(15)
      make.trailing.equalToSuperview().inset(14)
      make.width.height.equalTo(44)
    }
  }
}
