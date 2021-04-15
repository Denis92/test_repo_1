//
//  CheckPhotosViewController.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

class CheckPhotosViewController: BaseViewController, NavigationBarHiding {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    if #available(iOS 13.0, *) {
      return .darkContent
    } else {
      return .default
    }
  }

  // MARK: - Outlets
  private let actvityIndicator = ActivityIndicatorView()
  private let imageTextContainer = UIView()
  private let resultImageView = UIImageView()
  private let resultLabel = AttributedLabel(textStyle: .title2Bold)
  private let bottomButton = StandardButton(type: .primary)
  
  // MARK: - Properties
  private var imageViewBottomConstraint: Constraint?
  private var activityIndicatorBottomConstraint: Constraint?
  
  private let viewModel: CheckPhotosViewModel
  
  // MARK: - Init
  
  init(viewModel: CheckPhotosViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
    viewModel.load()
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupImageTextContainer()
    setupActivityIndicator()
    setupResultImageView()
    setupResultLabel()
    setupBottomButton()
  }
  
  private func bind() {
    viewModel.onDidReceiveServerError = { [weak self] _ in
      self?.setupErrorState()
    }
    viewModel.onDidReceiveNoInternetError = { [weak self] _ in
      self?.setupNoInternetState()
    }
    viewModel.onDidStartRequest = { [weak self] in
      self?.setupPendingState()
    }
    viewModel.onDidReceiveSuccessResult = { [weak self] in
      self?.setupSuccessState()
    }
    viewModel.onDidReceiveFailResult = { [weak self] in
      self?.setupFailState()
    }
  }
  
  private func setupPendingState() {
    actvityIndicator.isAnimating = true
    resultImageView.isHidden = true
    imageViewBottomConstraint?.deactivate()
    activityIndicatorBottomConstraint?.activate()
    resultLabel.text = R.string.checkPhotos.pendingStateText()
    bottomButton.isHidden = true
  }
  
  private func setupSuccessState() {
    actvityIndicator.isAnimating = false
    resultImageView.image = R.image.successCheckPhotos()
    resultImageView.isHidden = false
    activityIndicatorBottomConstraint?.deactivate()
    imageViewBottomConstraint?.activate()
    resultLabel.text = R.string.checkPhotos.successStateText()
    bottomButton.isHidden = true
  }
  
  private func setupFailState() {
    actvityIndicator.isAnimating = false
    resultImageView.image = R.image.failCheckPhotos()
    resultImageView.isHidden = false
    activityIndicatorBottomConstraint?.deactivate()
    imageViewBottomConstraint?.activate()
    resultLabel.text = R.string.checkPhotos.failStateText()
    bottomButton.isHidden = false
    bottomButton.setTitle(R.string.checkPhotos.repeatButtonTitle(), for: .normal)
  }
  
  private func setupErrorState() {
    setupFailState()
    resultLabel.text = R.string.checkPhotos.errorStateText()
  }

  private func setupNoInternetState() {
    setupFailState()
    resultLabel.text = R.string.checkPhotos.networkErrorStateText()
  }
  
  private func setupActivityIndicator() {
    view.addSubview(actvityIndicator)
    actvityIndicator.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().multipliedBy(0.9)
    }
  }

  private func setupImageTextContainer() {
    view.addSubview(imageTextContainer)
    imageTextContainer.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(30)
      make.centerY.equalToSuperview()
    }
  }
  
  private func setupResultImageView() {
    imageTextContainer.addSubview(resultImageView)
    resultImageView.contentMode = .scaleAspectFit
    resultImageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
  }
  
  private func setupResultLabel() {
    imageTextContainer.addSubview(resultLabel)
    resultLabel.textColor = .base1
    resultLabel.textAlignment = .center
    resultLabel.numberOfLines = 0
    resultLabel.snp.makeConstraints { make in
      imageViewBottomConstraint = make.top.equalTo(resultImageView.snp.bottom).offset(32).constraint
      activityIndicatorBottomConstraint = make.top.equalTo(actvityIndicator.snp.bottom).offset(32).constraint
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  private func setupBottomButton() {
    view.addSubview(bottomButton)
    bottomButton.addTarget(self, action: #selector(didTapBottomButton), for: .touchUpInside)
    bottomButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(40)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  // MARK: - Actions
  @objc private func didTapBottomButton() {
    viewModel.didTapBottomButton()
  }
}
