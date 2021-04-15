//
//  OnboardingViewController.swift
//  ForwardLeasing
//

import UIKit

class OnboardingViewController: UIViewController, NavigationBarHiding {
  private let viewModel: OnboardingViewModel
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Subviews
  private let scrollView = UIScrollView()
  private let pagesStackView = UIStackView()
  private let buttonsStackView = UIStackView()
  private let arrowBackButton = UIButton(type: .system)
  private let skipButton = UIButton(type: .system)
  private let backButton = UIButton(type: .system)
  private let nextButton = StandardButton(type: .primary)
  private let pageControl = OnboardingPageControlView()
  
  // MARK: - Init
  init(viewModel: OnboardingViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    bindToViewModel()
  }
  
  // MARK: - Configure
  func configure() {
    skipButton.setTitle(viewModel.skipButtonTitle, for: .normal)
    backButton.setTitle(viewModel.backButtonTitle, for: .normal)
    nextButton.setTitle(viewModel.nextButtonTitle, for: .normal)
    viewModel.itemViewModels.forEach {
      let page = OnboardingPageView()
      page.configure(with: $0)
      pagesStackView.addArrangedSubview(page)
      page.snp.makeConstraints { make in
        make.size.equalTo(scrollView)
      }
    }
  }
  
  // MARK: - Setup
  private func setup() {
    setupScrollView()
    setupPagesStackView()
    setupArrowBackButton()
    setupSkipButton()
    setupButtonsStackView()
    setupBackButton()
    setupNextButton()
    setupPageControl()
    configure()
  }
  
  private func setupScrollView() {
    view.addSubview(scrollView)
    scrollView.delegate = self
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isPagingEnabled = true
    scrollView.bounces = false
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.snp.makeConstraints { make in
      make.height.equalToSuperview()
      make.top.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  private func setupPagesStackView() {
    scrollView.addSubview(pagesStackView)
    pagesStackView.axis = .horizontal
    pagesStackView.snp.makeConstraints { make in
      make.height.equalTo(view)
      make.edges.equalToSuperview()
    }
  }
  
  private func setupArrowBackButton() {
    view.addSubview(arrowBackButton)
    arrowBackButton.setImage(R.image.backButtonWithBackgroundIcon()?.withRenderingMode(.alwaysOriginal),
                             for: .normal)
    arrowBackButton.addTarget(self, action: #selector(didTapArrowBackButton), for: .touchUpInside)
    arrowBackButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.equalToSuperview().inset(15)
      make.size.equalTo(32)
    }
  }
  
  private func setupSkipButton() {
    view.addSubview(skipButton)
    skipButton.setTitleColor(.base2, for: .normal)
    skipButton.titleLabel?.font = .title3Semibold
    skipButton.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
    skipButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.trailing.equalToSuperview().offset(-16)
    }
  }
  
  private func setupBackButton() {
    buttonsStackView.addArrangedSubview(backButton)
    backButton.isHidden = true
    backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    backButton.setTitleColor(.base2, for: .normal)
    backButton.backgroundColor = .accent2Light
    backButton.titleLabel?.font = .title2Semibold
    backButton.makeRoundedCorners(radius: 30)
  }
  
  private func setupNextButton() {
    buttonsStackView.addArrangedSubview(nextButton)
    nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
  }
  
  private func setupButtonsStackView() {
    view.addSubview(buttonsStackView)
    buttonsStackView.spacing = 16
    buttonsStackView.distribution = .fillEqually
    buttonsStackView.snp.makeConstraints { make in
      make.bottom.equalToSuperview().offset(-40)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupPageControl() {
    view.addSubview(pageControl)
    pageControl.numberOfPages = viewModel.numberOfPages
    pageControl.currentPage = 0
    pageControl.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.bottom.equalTo(buttonsStackView.snp.top).offset(-110)
    }
  }
  
  // MARK: - Update view
  private func updateView() {
    nextButton.setTitle(viewModel.nextButtonTitle, for: .normal)
    if viewModel.currentPageIndex == 0 {
      setButtonHidden(true)
    } else {
      setButtonHidden(false)
    }
    skipButton.isHidden = viewModel.isTheLastPage
    pageControl.currentPage = viewModel.currentPageIndex
  }
  
  // MARK: - Animate
  private func setButtonHidden(_ isHidden: Bool) {
    UIView.animate(withDuration: 0.2) {
      self.backButton.isHidden = isHidden
    }
  }
  
  // MARK: - Button methods
  @objc private func didTapNextButton() {
    guard !viewModel.isTheLastPage else {
      viewModel.finish()
      return
    }
    viewModel.setCurrentPage(index: viewModel.currentPageIndex + 1)
    let offsetX = CGFloat(viewModel.currentPageIndex) * scrollView.frame.size.width
    scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    updateView()
  }
  
  @objc private func didTapBackButton() {
    guard viewModel.currentPageIndex > 0 else { return }
    viewModel.setCurrentPage(index: viewModel.currentPageIndex - 1)
    let offsetX = CGFloat(viewModel.currentPageIndex) * self.view.bounds.width
    scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    updateView()
  }
  
  @objc private func didTapSkipButton() {
    viewModel.finish()
  }
  
  @objc private func didTapArrowBackButton() {
    viewModel.close()
  }
  
  // MARK: - Bind to ViewModel
  private func bindToViewModel() {
    viewModel.onDidUpdatePage = { [weak self] in
      guard let self = self else { return }
      self.updateView()
    }
  }
}

// MARK: - UIScrollViewDelegate
extension OnboardingViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let currentPage = getCurrentPage()
    viewModel.showPage(at: currentPage)
  }
  
  private func getCurrentPage() -> Int {
    guard scrollView.bounds.size.width > 0 else { return 0 }
    return Int(round(scrollView.contentOffset.x / scrollView.bounds.size.width))
  }
}
