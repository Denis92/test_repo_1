//
//  QuestionnaireViewController.swift
//  ForwardLeasing
//

import UIKit

protocol QuestionnaireViewControllerDelegate: class {
  func questionnaireViewControllerDidRequestGoBack(_ viewController: QuestionnaireViewController)
}

class QuestionnaireViewController: RegularNavBarViewController, ActivityIndicatorEmptyViewPresenting {
  // MARK: - Subviews
  let activityIndicatorContainer = UIView()
  let activityIndicator = ActivityIndicatorView()
  
  weak var delegate: QuestionnaireViewControllerDelegate?
  
  private let contentView = UIView()
  private let productInfoView = QuestionnaireProductInfoView()
  private let questionnaireView = ProductQuestionnaireView()
  private let continueButton = StandardButton(type: .primary)
  
  // MARK: - Properties
  private let viewModel: QuestionnaireViewModel
  
  // MARK: - Init
  init(viewModel: QuestionnaireViewModel) {
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
    setupNavigationBarView(title: viewModel.title) { [weak self] in
      guard let self = self else { return }
      self.delegate?.questionnaireViewControllerDidRequestGoBack(self)
    }
    setupScrollView()
    setupContentView()
    setupProductInfoView()
    setupQuestionnaireView()
    setupContinueButton()
    setupActivityIndicator()
  }
  
  private func bind() {
    viewModel.onDidStartRequest = { [weak self] in
      self?.showActivityIndicator()
    }
    viewModel.onDidFinishRequest = { [weak self] in
      self?.hideActivityIndicator()
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.handle(error: error)
    }
    viewModel.onDidUpdateViewModels = { [weak self] in
      self?.updateQuestionnaire()
    }
  }
  
  private func updateQuestionnaire() {
    updateProductInfoView()
    updateQuestionnaireView()
  }
  
  private func setupContentView() {
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.greaterThanOrEqualToSuperview()
      make.width.equalToSuperview()
    }
  }
  
  private func updateProductInfoView() {
    guard let productInfoViewModel = viewModel.productInfoViewModelType else {
      return
    }
    productInfoView.configure(with: productInfoViewModel)
  }
  
  private func updateQuestionnaireView() {
    guard let questionnaireViewModel = viewModel.productQuestionnaireViewModel else {
      return
    }
    questionnaireView.configure(with: questionnaireViewModel)
  }
  
  private func setupProductInfoView() {
    contentView.addSubview(productInfoView)
    productInfoView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupQuestionnaireView() {
    contentView.addSubview(questionnaireView)
    questionnaireView.snp.makeConstraints { make in
      make.top.equalTo(productInfoView.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupContinueButton() {
    contentView.addSubview(continueButton)
    continueButton.setTitle(R.string.common.continue(), for: .normal)
    continueButton.actionHandler(controlEvents: .touchUpInside) { [weak self] in
      self?.viewModel.finish()
    }
    continueButton.snp.makeConstraints { make in
      make.top.equalTo(questionnaireView.snp.bottom).offset(40)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(40)
    }
  }
}
