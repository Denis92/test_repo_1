//
//  SubcategoryFiltersViewController.swift
//  ForwardLeasing
//

import UIKit

class SubcategoryFiltersViewController: BaseBottomSheetViewController {
  // MARK: - Properties

  private let titleLabel = AttributedLabel(textStyle: .title1Bold)
  private let bottomButtonsContainerView = UIView()
  private let dividerView = UIView()
  private let scrollView = UIScrollView()
  private let stackView = UIStackView()
  private let clearButton = StandardButton(type: .secondary)
  private let applyButton = StandardButton(type: .primary)

  private let viewModel: SubcategoryFiltersViewModel

  // MARK: - Init

  init(viewModel: SubcategoryFiltersViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    stackView.layoutIfNeeded()
    configure(with: viewModel)
  }

  // MARK: - Configure

  private func configure(with viewModel: SubcategoryFiltersViewModel) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    stackView.layoutIfNeeded()
    
    for sectionViewModel in viewModel.colorFilterViewModels {
      let view = SubcategoryColorFilterSectionView()
      stackView.addArrangedSubview(view)
      view.configure(with: sectionViewModel)
    }

    for sectionViewModel in viewModel.filterViewModels {
      let view = SubcategoryFilterSectionView(containerWidth: stackView.bounds.width)
      stackView.addArrangedSubview(view)
      view.configure(with: sectionViewModel)
    }
  }
  
  // MARK: - Actions
  
  @objc private func didTapClearButton() {
    viewModel.reset()
  }
  
  @objc private func didTapApplyButton() {
    viewModel.finish()
  }

  // MARK: - Setup

  private func setup() {
    addTitleLabel()
    addBottomButtonsContainerView()
    addDividerView()
    addScrollView()
    addStackView()
    addClearButton()
    addApplyButton()
  }

  private func addTitleLabel() {
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalTo(closeButton.snp.leading).inset(16)
      make.top.equalToSuperview().offset(28)
    }
    titleLabel.text = R.string.catalogue.subcategoryFiltersTitle()
  }
  
  private func addBottomButtonsContainerView() {
    view.addSubview(bottomButtonsContainerView)
    bottomButtonsContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      make.bottom.equalTo(view.safeAreaLayoutGuide).priority(250)
      make.bottom.greaterThanOrEqualToSuperview().offset(-24)
    }
  }
  
  private func addDividerView() {
    bottomButtonsContainerView.addSubview(dividerView)
    dividerView.backgroundColor = .shade30
    dividerView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(0.5)
    }
  }

  private func addScrollView() {
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(28)
      make.bottom.equalTo(bottomButtonsContainerView.snp.top)
      make.leading.trailing.equalToSuperview()
    }
    scrollView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.showsVerticalScrollIndicator = false
  }

  private func addStackView() {
    scrollView.addSubview(stackView)
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 32
    stackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.bottom.equalToSuperview()
      make.width.equalTo(view).offset(-40)
    }
  }
  
  private func addClearButton() {
    bottomButtonsContainerView.addSubview(clearButton)
    clearButton.setTitle(R.string.catalogue.subcategoryFiltersClear(), for: .normal)
    clearButton.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
    clearButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.bottom.equalToSuperview().inset(16)
    }
  }
  
  private func addApplyButton() {
    bottomButtonsContainerView.addSubview(applyButton)
    applyButton.setTitle(R.string.catalogue.subcategoryFiltersApply(), for: .normal)
    applyButton.addTarget(self, action: #selector(didTapApplyButton), for: .touchUpInside)
    applyButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(20)
      make.top.bottom.equalToSuperview().inset(16)
      make.leading.equalTo(clearButton.snp.trailing).offset(12)
      make.width.equalTo(clearButton.snp.width).multipliedBy(1.2)
    }
  }
}
