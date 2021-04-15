//
//  BaseBottomSheetViewController.swift
//  ForwardLeasing
//

import UIKit

class BaseBottomSheetViewController: BottomSheetViewController {
  // MARK: - Properties

  override var cornerRadius: CGFloat {
    return 24
  }
  
  let closeButton = UIButton(type: .system)
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addCloseButton()
    forceLayout()
  }
  
  // MARK: - Public Methods
  
  func forceLayout() {
    view.setNeedsLayout()
    view.layoutIfNeeded()
  }
  
  // MARK: - Actions
  
  @objc private func handleCloseButtonTapped() {
    removeBottomSheetViewController(animated: true)
  }
  
  // MARK: - Private Methods

  private func addCloseButton() {
    view.addSubview(closeButton)
    
    closeButton.setImage(R.image.bottomSheetCloseIcon(), for: .normal)
    closeButton.tintColor = .shade60
    closeButton.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
    
    closeButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(18)
      make.trailing.equalToSuperview().inset(10)
      make.width.height.equalTo(44)
    }
  }
}

// MARK: - Add Bottom Sheet

extension UIViewController {
  func addBottomSheetViewController(viewController: BottomSheetViewController,
                                    animated: Bool,
                                    initialAnchorPointOffset: CGFloat) {
    addBottomSheetViewController(withDarkView: true,
                                 viewController: viewController,
                                 initialAnchorPointOffset: initialAnchorPointOffset,
                                 animated: animated,
                                 sheetType: .hiding)
  }
}
