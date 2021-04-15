//
//  PassportScanCameraViewController.swift
//  ForwardLeasing
//

import UIKit
import AVFoundation

private extension Constants {
  static let gradientStartColor = UIColor(red: 0.09, green: 0.03, blue: 0.32, alpha: 1)
  static let gradientEndColor = UIColor(red: 0.09, green: 0.03, blue: 0.32, alpha: 0)
}

protocol PassportScanCameraViewControllerDelegate: class {
  func passportScanCameraViewControllerDidFinish(_ viewController: PassportScanCameraViewController)
}

class PassportScanCameraViewController: BaseViewController {
  // MARK: - Properties
  
  weak var delegate: PassportScanCameraViewControllerDelegate?
  
  private let cameraPreviewView = UIView()
  private let gradientView = UIView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let closeButton = UIButton(type: .system)
  private let scanButton = StandardButton(type: .primary)
  
  private let viewModel: PassportScanCameraViewModel
  
  private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
  private var isViewDidAppear = false
  private var onNeedsToShowErrorBanner: (() -> Void)?
  
  // MARK: - Init
  
  init(viewModel: PassportScanCameraViewModel) {
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
    viewModel.onViewIsReady()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    isViewDidAppear = true
    onNeedsToShowErrorBanner?()
    onNeedsToShowErrorBanner = nil
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    previewLayer.frame = cameraPreviewView.frame
    gradientView.addGradient(startColor: Constants.gradientStartColor,
                             endColor: Constants.gradientEndColor, direction: .vertical)
  }
  
  // MARK: - Actions
  
  @objc private func didTapCloseButton() {
    delegate?.passportScanCameraViewControllerDidFinish(self)
  }
  
  @objc private func didTapScanButton() {
    viewModel.takePhoto()
  }
  
  // MARK: - Setup
  
  private func setup() {
    view.backgroundColor = .base1
    setupCameraPreviewView()
    setupGradientView()
    setupCloseButton()
    setupTitleLabel()
    setupScanButton()
  }
  
  private func setupCameraPreviewView() {
    view.addSubview(cameraPreviewView)
    
    previewLayer.videoGravity = .resizeAspectFill
    previewLayer.connection?.videoOrientation = .portrait
    cameraPreviewView.layer.addSublayer(previewLayer)
    
    cameraPreviewView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupGradientView() {
    view.addSubview(gradientView)
    
    gradientView.snp.makeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
      make.height.equalTo(156 + UIApplication.shared.statusBarFrame.height)
    }
  }
  
  private func setupCloseButton() {
    view.addSubview(closeButton)
    
    closeButton.setImage(R.image.closeIcon(), for: .normal)
    closeButton.tintColor = .base2
    closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    
    closeButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.leading.equalToSuperview().inset(20)
      make.size.equalTo(40)
    }
  }
  
  private func setupTitleLabel() {
    view.addSubview(titleLabel)
    
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    titleLabel.textColor = .base2
    titleLabel.text = R.string.scanPassport.cameraScreenTitle()
    
    titleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(16)
      make.top.equalTo(closeButton.snp.bottom).offset(8)
    }
  }
  
  private func setupScanButton() {
    view.addSubview(scanButton)
    scanButton.setTitle(R.string.scanPassport.scanButtonTitle(), for: .normal)
    scanButton.addTarget(self, action: #selector(didTapScanButton), for: .touchUpInside)
    scanButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(40).priority(250)
      make.bottom.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(-24)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  // MARK: - View Model
  
  private func bindToViewModel() {
    viewModel.onDidStartCapturingPhoto = { [weak self] in
      self?.scanButton.startAnimating()
    }
    viewModel.onDidReceiveError = { [weak self] error in
      if self?.isViewDidAppear == true {
        self?.showErrorBanner(error: error)
      } else {
        self?.onNeedsToShowErrorBanner = { [weak self] in
          self?.showErrorBanner(error: error)
        }
      }
      
      if (error as? PassportScanCameraError) == .cameraNotSupported {
        self?.scanButton.isEnabled = false
      }
    }
  }
}
