//
//  SelfieViewController.swift
//  ForwardLeasing
//

import UIKit

protocol SelfieViewControllerDelegate: class {
  func selfieViewControllerDidFinish(_ viewController: SelfieViewController)
}

class SelfieViewController: BaseViewController, NavigationBarHiding, ActivityIndicatorViewDisplaying,
                            ErrorEmptyViewDisplaying, ViewModelBinding {
  // MARK: - Properties
  
  weak var delegate: SelfieViewControllerDelegate?
  
  override var title: String? {
    didSet {
      navigationBarView.configureNavigationBarTitle(title: title)
    }
  }
  
  let navigationBarView = NavigationBarView(type: .titleWithoutContent)
  let activityIndicatorView = ActivityIndicatorView()
  let errorEmptyView = ErrorEmptyView()
  
  private let titleLabel = AttributedLabel(textStyle: .title1Bold)
  private let descriptionLabel = AttributedLabel(textStyle: .textRegular)
  private let makeSelfieButton = StandardButton(type: .primary)
  
  private let viewModel: SelfieViewModel
  
  // MARK: - Init
  
  init(viewModel: SelfieViewModel) {
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
    bind(to: viewModel)
    viewModel.loadData()
  }
  
  // MARK: - Public methods
  
  func handleRequestStarted(shouldShowActivityIndicator: Bool) {
    titleLabel.isHidden = true
    descriptionLabel.isHidden = true
    makeSelfieButton.isHidden = true
  }
  
  func reloadViews() {
    titleLabel.isHidden = false
    descriptionLabel.isHidden = false
    makeSelfieButton.isHidden = false
  }
  
  func handleEmptyViewRefreshButtonTapped() {
    viewModel.loadData()
  }
  
  // MARK: - Actions
  
  @objc private func didTapMakeSelfieButton() {
    viewModel.takeSelfiePhoto()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupNavigationBarView()
    setupTitleLabel()
    setupDescriptionLabel()
    setupMakeSelfieButton()
    addActivityIndicatorView()
    addErrorEmptyView()
  }
  
  private func setupNavigationBarView() {
    view.addSubview(navigationBarView)
    navigationBarView.addBackButton { [unowned self] in
      self.delegate?.selfieViewControllerDidFinish(self)
    }
    navigationBarView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupTitleLabel() {
    view.addSubview(titleLabel)
    
    titleLabel.numberOfLines = 0
    titleLabel.textColor = .base1
    titleLabel.text = R.string.selfie.titleText()
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(navigationBarView.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupDescriptionLabel() {
    view.addSubview(descriptionLabel)
    
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textColor = .base1
    descriptionLabel.text = R.string.selfie.descriptionText()
    
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(14)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupMakeSelfieButton() {
    view.addSubview(makeSelfieButton)
    
    makeSelfieButton.setTitle(R.string.selfie.makeSelfieButtonTitle(), for: .normal)
    makeSelfieButton.addTarget(self, action: #selector(didTapMakeSelfieButton), for: .touchUpInside)
    
    makeSelfieButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(40).priority(250)
      make.bottom.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(-24)
      make.leading.trailing.equalToSuperview().inset(20)
    }
    
  }
}
