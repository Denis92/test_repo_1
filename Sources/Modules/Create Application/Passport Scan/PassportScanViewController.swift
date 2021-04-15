//
//  PassportScanViewController.swift
//  ForwardLeasing
//

import UIKit

protocol PassportScanViewControllerDelegate: class {
  func passportScanViewControllerDidFinish(_ viewController: PassportScanViewController)
}

class PassportScanViewController: BaseViewController, NavigationBarHiding {
  // MARK: - Properties
  
  weak var delegate: PassportScanViewControllerDelegate?
  
  override var title: String? {
    didSet {
      navigationBarView.configureNavigationBarTitle(title: title)
    }
  }
  
  let navigationBarView = NavigationBarView(type: .titleWithoutContent)
  
  private let titleLabel = AttributedLabel(textStyle: .title1Bold)
  private let descriptionLabel = AttributedLabel(textStyle: .textRegular)
  private let takePhotoButton = StandardButton(type: .primary)
  private let uploadFromGalleryButton = StandardButton(type: .clear)
  private let activityIndicatorOverlayView = UIView()
  private let activityIndicatorView = ActivityIndicatorView(style: .whiteLarge, color: .base2)
  
  private let viewModel: PassportScanViewModel
  
  // MARK: - Init
  
  init(viewModel: PassportScanViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bindToViewModel()
  }
  
  // MARK: - Actions
  
  @objc private func didTapTakePhotoButton() {
    viewModel.takePhoto()
  }
  
  @objc private func didTapUploadFromLibraryButton() {
    viewModel.uploadFromLibrary()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupNavigationBarView()
    setupTitleLabel()
    setupDescriptionLabel()
    setupUploadFromGalleryButton()
    setupTakePhotoButton()
    setupActivityIndicatorView()
  }
  
  private func setupNavigationBarView() {
    view.addSubview(navigationBarView)
    navigationBarView.addBackButton { [unowned self] in
      self.delegate?.passportScanViewControllerDidFinish(self)
    }
    navigationBarView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupTitleLabel() {
    view.addSubview(titleLabel)
    
    titleLabel.numberOfLines = 0
    titleLabel.textColor = .base1
    titleLabel.text = R.string.scanPassport.titleText()
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(navigationBarView.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupDescriptionLabel() {
    view.addSubview(descriptionLabel)
    
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textColor = .base1
    descriptionLabel.text = R.string.scanPassport.descriptionText()
    
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(14)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupUploadFromGalleryButton() {
    view.addSubview(uploadFromGalleryButton)
    
    uploadFromGalleryButton.setTitle(R.string.scanPassport.uploadFromGalleryButtonTitle(),
                                     for: .normal)
    uploadFromGalleryButton.addTarget(self, action: #selector(didTapUploadFromLibraryButton),
                                      for: .touchUpInside)
    
    uploadFromGalleryButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(40).priority(250)
      make.bottom.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(-24)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupTakePhotoButton() {
    view.addSubview(takePhotoButton)
    
    takePhotoButton.setTitle(R.string.scanPassport.takePhotoButtonTitle(),
                             for: .normal)
    takePhotoButton.addTarget(self, action: #selector(didTapTakePhotoButton), for: .touchUpInside)
    
    takePhotoButton.snp.makeConstraints { make in
      make.bottom.equalTo(uploadFromGalleryButton.snp.top).offset(-16)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupActivityIndicatorView() {
    view.addSubview(activityIndicatorOverlayView)
    activityIndicatorOverlayView.backgroundColor = UIColor.base1.withAlphaComponent(0.6)
    activityIndicatorOverlayView.isHidden = true
    activityIndicatorOverlayView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    activityIndicatorOverlayView.addSubview(activityIndicatorView)
    activityIndicatorView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - View Model
  
  private func bindToViewModel() {
    viewModel.onDidStartRequest = { [weak self] in
      self?.activityIndicatorView.startAnimating()
      self?.activityIndicatorOverlayView.isHidden = false
    }
    viewModel.onDidFinishRequest = { [weak self] in
      self?.activityIndicatorView.stopAnimating()
      self?.activityIndicatorOverlayView.isHidden = true
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.showErrorBanner(error: error)
    }
  }
}
