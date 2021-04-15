//
//  StoreInfoView.swift
//  ForwardLeasing
//

import UIKit

protocol StoreInfoViewModelProtocol {
  var storePointInfo: StorePointInfo? { get }
  func didTapSelectOtherStore()
}

enum StoreInfoViewStyle {
  case mapBottomSheet, signedContract
}

class StoreInfoView: UIStackView, Configurable {
  // MARK: - Properties
  
  var onTapSelectOtherStore: (() -> Void)?
  var onNeedsToPresentViewController: ((_ viewController: UIViewController) -> Void)?
  
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let addressStackView = UIStackView()
  private let addressLabel = AttributedLabel(textStyle: .textRegular)
  private let copyAddressButton = UIButton(type: .system)
  private let storeNameLabel = AttributedLabel(textStyle: .textBold)
  private let actionsStackView = UIStackView()
  private let storePhoneButton = UIButton(type: .system)
  private let navigationButton = UIButton(type: .system)
  private let workHoursLabel = AttributedLabel(textStyle: .textRegular)
  private let selectOtherStoreButton = UIButton(type: .system)
  
  private let style: StoreInfoViewStyle
  
  private var storePointInfo: StorePointInfo?
  private var viewModel: StoreInfoViewModelProtocol?
  
  private var canOpenGoogleMaps: Bool {
    if let googleMapsURL = URL(string: "comgooglemaps://"), UIApplication.shared.canOpenURL(googleMapsURL) {
      return true
    }
    return false
  }
  
  private var canOpenAppleMaps: Bool {
    if let appleMapURL = URL(string: "https://maps.apple.com"), UIApplication.shared.canOpenURL(appleMapURL) {
      return true
    }
    return false
  }
  
  // MARK: - Init
  override init(frame: CGRect) {
    style = .signedContract
    super.init(frame: frame)
    setup()
  }
  
  init(style: StoreInfoViewStyle) {
    self.style = style
    super.init(frame: .zero)
    setup()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(storePointInfo: StorePointInfo?) {
    addressLabel.text = storePointInfo?.address
    storeNameLabel.text = storePointInfo?.name
    workHoursLabel.text = storePointInfo?.workInfo
    self.storePointInfo = storePointInfo
  }
  
  func configure(with viewModel: StoreInfoViewModelProtocol) {
    self.viewModel = viewModel
    configure(storePointInfo: viewModel.storePointInfo)
  }
  
  // MARK: - Actions
  
  @objc private func copyAddress() {
    guard addressLabel.text != nil else { return }
    UIPasteboard.general.string = addressLabel.text
    showBanner(text: R.string.signedContract.pickupStoreInfoAddressWasCopiedText())
  }
  
  @objc private func callToStore() {
    if let phone = storePointInfo?.phone, let url = URL(string: "tel://" + phone) {
      UIApplication.shared.open(url)
    }
  }
  
  @objc private func openMaps() {
    if canOpenGoogleMaps && canOpenAppleMaps {
      showMapApplicationSelection()
    } else if canOpenGoogleMaps {
      openGoogleMaps()
    } else if canOpenAppleMaps {
      openAppleMaps()
    }
  }
  
  @objc private func selectOtherStore() {
    onTapSelectOtherStore?()
    viewModel?.didTapSelectOtherStore()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    if style == .signedContract {
      setupTitleLabel()
    }
    setupAddressStackView()
    setupAddressLabel()
    setupCopyAddressButton()
    setupStoreNameLabel()
    setupWorkHoursLabel()
    setupActionsStackView()
    setupNavigationButton()
    setupStorePhoneButton()
    if style == .signedContract {
      setupSelectOtherStoreButton()
    }
  }
  
  private func setupContainer() {
    axis = .vertical
    spacing = 12
    alignment = .leading
  }
  
  private func setupTitleLabel() {
    addArrangedSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.text = R.string.signedContract.pickupStoreInfoTitleText()
  }
  
  private func setupAddressStackView() {
    addArrangedSubview(addressStackView)
    addressStackView.axis = .horizontal
    addressStackView.spacing = 16
    addressStackView.alignment = .center
  }
  
  private func setupAddressLabel() {
    addressStackView.addArrangedSubview(addressLabel)
    addressLabel.numberOfLines = 0
    addressLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    addressLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
  }
  
  private func setupCopyAddressButton() {
    addressStackView.addArrangedSubview(copyAddressButton)
    copyAddressButton.tintColor = .accent
    copyAddressButton.setImage(R.image.copy(), for: .normal)
    copyAddressButton.addTarget(self, action: #selector(copyAddress), for: .touchUpInside)
    copyAddressButton.snp.makeConstraints { make in
      make.size.equalTo(24)
    }
  }
  
  private func setupStoreNameLabel() {
    addArrangedSubview(storeNameLabel)
    storeNameLabel.numberOfLines = 0
  }
  
  private func setupWorkHoursLabel() {
    addArrangedSubview(workHoursLabel)
    workHoursLabel.numberOfLines = 0
    setCustomSpacing(16, after: workHoursLabel)
  }
  
  private func setupActionsStackView() {
    addArrangedSubview(actionsStackView)
    actionsStackView.axis = .horizontal
    actionsStackView.spacing = 24
    setCustomSpacing(24, after: actionsStackView)
  }
  
  private func setupNavigationButton() {
    actionsStackView.addArrangedSubview(navigationButton)
    navigationButton.setImage(R.image.navigationButton(), for: .normal)
    navigationButton.tintColor = .accent
    navigationButton.addTarget(self, action: #selector(openMaps), for: .touchUpInside)
    navigationButton.snp.makeConstraints { make in
      make.size.equalTo(48)
    }
    
    navigationButton.isHidden = !canOpenGoogleMaps && !canOpenAppleMaps
  }
  
  private func setupStorePhoneButton() {
    actionsStackView.addArrangedSubview(storePhoneButton)
    storePhoneButton.setImage(R.image.callButton(), for: .normal)
    storePhoneButton.tintColor = .access
    storePhoneButton.addTarget(self, action: #selector(callToStore), for: .touchUpInside)
    storePhoneButton.snp.makeConstraints { make in
      make.size.equalTo(48)
    }
  }
  
  private func setupSelectOtherStoreButton() {
    addArrangedSubview(selectOtherStoreButton)
    selectOtherStoreButton.layer.cornerRadius = 20
    selectOtherStoreButton.layer.borderWidth = 1
    selectOtherStoreButton.layer.borderColor = UIColor.accent.cgColor
    selectOtherStoreButton.setTitle(R.string.signedContract.pickupStoreInfoSelectOtherButtonTitle(), for: .normal)
    selectOtherStoreButton.setImage(R.image.mapPinIcon(), for: .normal)
    selectOtherStoreButton.tintColor = .accent
    selectOtherStoreButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 34)
    selectOtherStoreButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
    selectOtherStoreButton.semanticContentAttribute = UIApplication.shared
        .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
    selectOtherStoreButton.addTarget(self, action: #selector(selectOtherStore), for: .touchUpInside)
    selectOtherStoreButton.snp.makeConstraints { make in
      make.height.equalTo(40)
    }
  }
  
  private func openAppleMaps() {
    guard let storePointInfo = storePointInfo else { return }
    let query = "q=\(storePointInfo.name.encodedURLString)&ll=\(storePointInfo.latitude),\(storePointInfo.longitude)"
    if let addressURL = URL(string: "https://maps.apple.com/?\(query)") {
      UIApplication.shared.open(addressURL)
    }
  }
  
  private func openGoogleMaps() {
    guard let storePointInfo = storePointInfo else { return }
    let query = "\(storePointInfo.name.encodedURLString)@\(storePointInfo.latitude),\(storePointInfo.longitude)"
    if let addressURL = URL(string: "comgooglemaps://?q=\(query)") {
      UIApplication.shared.open(addressURL)
    }
  }
  
  private func showMapApplicationSelection() {
    let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    controller.addAction(UIAlertAction(title: R.string.signedContract.openAppleMapsActionTitle(),
                                       style: .default) { [weak self] _ in
      self?.openAppleMaps()
    })
    controller.addAction(UIAlertAction(title: R.string.signedContract.openGoogleMapsActionTitle(),
                                       style: .default) { [weak self] _ in
      self?.openGoogleMaps()
    })
    controller.addAction(UIAlertAction(title: R.string.common.cancel(), style: .cancel) { [weak controller] _ in
      controller?.dismiss(animated: true, completion: nil)
    })
    onNeedsToPresentViewController?(controller)
  }
}
