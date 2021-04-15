//
//  PickupPlaceView.swift
//  ForwardLeasing
//

import UIKit

protocol PickupPlaceViewModelProtocol {
  var storePointInfo: StorePointInfo { get }
  var pickupButtonTitle: String { get }
  var onDidTapClose: (() -> Void)? { get }
  var onDidTapPickup: (() -> Void)? { get }
}

class PickupPlaceView: UIView, Configurable {
  var onNeedsToPresentViewController: ((_ viewController: UIViewController) -> Void)? {
    didSet {
      storeInfoView.onNeedsToPresentViewController = onNeedsToPresentViewController
    }
  }
  
  // MARK: - Subviews
  private let closeButton = UIButton(type: .system)
  private let storeInfoView = StoreInfoView(style: .mapBottomSheet)
  private let pickupButton = StandardButton(type: .primary)
  
  // MARK: - Properties
  private var onDidTapClose: (() -> Void)?
  private var onDidTapPickup: (() -> Void)?
  
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
  
  func configure(with viewModel: PickupPlaceViewModelProtocol) {
    onDidTapClose = viewModel.onDidTapClose
    onDidTapPickup = viewModel.onDidTapPickup
    storeInfoView.configure(storePointInfo: viewModel.storePointInfo)
    pickupButton.setTitle(viewModel.pickupButtonTitle, for: .normal)
    setNeedsLayout()
    layoutIfNeeded()
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    backgroundColor = .base2
    makeRoundedCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
                       radius: 8)
    setupCloseButton()
    setupStoreInfoView()
    setupPickupButton()
  }
  
  private func setupCloseButton() {
    addSubview(closeButton)
    closeButton.setImage(R.image.bottomSheetCloseIcon(), for: .normal)
    closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    closeButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(12)
      make.size.equalTo(40)
    }
  }
  
  private func setupStoreInfoView() {
    addSubview(storeInfoView)
    storeInfoView.snp.makeConstraints { make in
      make.top.equalTo(closeButton.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupPickupButton() {
    addSubview(pickupButton)
    pickupButton.addTarget(self, action: #selector(didTapPickupButton), for: .touchUpInside)
    pickupButton.snp.makeConstraints { make in
      make.top.equalTo(storeInfoView.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(40)
    }
  }
}

// MARK: - Action
private extension PickupPlaceView {
  @objc func didTapCloseButton() {
    onDidTapClose?()
  }
  
  @objc func didTapPickupButton() {
    onDidTapPickup?()
  }
}
