//
//  QuestionnaireResultViewController.swift
//  ForwardLeasing
//

import UIKit

protocol QuestionnaireResultViewControllerDelegate: class {
  func questionnaireResultViewControllerDidRequestGoBack(_ viewController: QuestionnaireResultViewController)
}

class QuestionnaireResultViewController: RegularNavBarViewController {
  // MARK: - Subviews
  private let contentView = UIView()
  private let titleLabel = AttributedLabel(textStyle: .title1Bold)
  private let starsView = StarsView()
  private let descriptionLabel = AttributedLabel(textStyle: .textRegular)
  private let sumPriceLabel = AttributedLabel(textStyle: .title2Bold)
  private let priceListView = PriceListView()
  private let continueButton = StandardButton(type: .primary)
  
  // MARK: - Properties
  weak var delegate: QuestionnaireResultViewControllerDelegate?
  
  private let viewModel: QuestionnaireResultViewModelProtocol
  
  // MARK: - Init
  init(viewModel: QuestionnaireResultViewModelProtocol) {
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
    bindToViewModel()
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupNavigationBarView(title: viewModel.screenTitle) { [weak self] in
      guard let self = self else { return }
      self.delegate?.questionnaireResultViewControllerDidRequestGoBack(self)
    }
    setupScrollView()
    setupContentView()
    setupTitleLabel()
    setupStarsView()
    setupDescriptionLabel()
    setupSumPriceLabel()
    setupPriceListView()
    setupContinueButton()
  }
  
  private func setupContentView() {
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
      make.width.equalToSuperview().offset(-40)
      make.height.greaterThanOrEqualToSuperview()
    }
  }
  
  private func setupTitleLabel() {
    contentView.addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.text = viewModel.questionnaireFormatter.title
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(32)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupStarsView() {
    contentView.addSubview(starsView)
    starsView.configure(with: viewModel.starsViewModel)
    starsView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.leading.equalToSuperview()
    }
  }
  
  private func setupDescriptionLabel() {
    contentView.addSubview(descriptionLabel)
    descriptionLabel.text = viewModel.questionnaireFormatter.description
    descriptionLabel.numberOfLines = 0
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(starsView.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupSumPriceLabel() {
    contentView.addSubview(sumPriceLabel)
    sumPriceLabel.attributedText = viewModel.questionnaireFormatter.descriptionPrice
    sumPriceLabel.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupPriceListView() {
    contentView.addSubview(priceListView)
    priceListView.configure(with: viewModel.priceListViewModel)
    priceListView.snp.makeConstraints { make in
      make.top.equalTo(sumPriceLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupContinueButton() {
    contentView.addSubview(continueButton)
    continueButton.setTitle(R.string.common.further(), for: .normal)
    continueButton.actionHandler(controlEvents: .touchUpInside) { [weak self] in
      self?.viewModel.finish()
    }
    continueButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(40)
    }
  }

  private func bindToViewModel() {
    viewModel.onDidStartRequest = { [weak self] in
      self?.continueButton.startAnimating()
    }
    viewModel.onDidFinishRequest = { [weak self] in
      self?.continueButton.stopAnimating()
    }
    viewModel.onDidRequestToShowErrorBanner = { [weak self] error in
      self?.showErrorBanner(error: error)
    }
  }
}
