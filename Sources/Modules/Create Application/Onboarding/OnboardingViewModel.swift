//
//  OnboardingViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol OnboardingViewModelDelegate: class {
  func onboardingViewModelDidFinish(_ viewModel: OnboardingViewModel)
  func onboardingViewModelDidRequestToClose(_ viewModel: OnboardingViewModel)
}

enum OnboardingType {
  case order, exchange, `return`
}

class OnboardingViewModel {
  // MARK: - Properties
  weak var delegate: OnboardingViewModelDelegate?
  
  var onDidUpdatePage: (() -> Void)?
  var currentPageType: OnboardingPageType = .photoPage
  let itemViewModels: [OnboardingPageViewModel]

  var skipButtonTitle: String {
    return R.string.onboarding.skipButton()
  }
  
  private var goButtonTitle: String {
    return R.string.onboarding.goButton()
  }
  
  var nextButtonTitle: String {
    return currentPageType == pages.last ? R.string.onboarding.goButton() : R.string.onboarding.nextButton()
  }
  
  var backButtonTitle: String {
    return R.string.onboarding.backButton()
  }
  
  var isTheLastPage: Bool {
    return currentPageType == pages.last
  }
  
  var currentPageIndex: Int {
    return pages.firstIndex(of: currentPageType) ?? 0
  }
  
  var numberOfPages: Int {
    return pages.count
  }
  
  private let pages: [OnboardingPageType]

  init(type: OnboardingType) {
    switch type {
    case .order:
      pages = [.photoPage, .contractPage, .deliveryPage]
    case .exchange:
      pages = [.deviceStatePage, .contractPage, .deliveryPage]
    case .return:
      pages = [.deviceStatePage, .goToStorePage]
    }
    
    itemViewModels = pages.map {
      OnboardingPageViewModel(title: $0.title, pageNumberImage: $0.pageNumberImage)
    }
  }
  
  func showPage(at index: Int) {
    currentPageType = pages.element(at: index) ?? pages.first ?? .photoPage
    onDidUpdatePage?()
  }
  
  func setCurrentPage(index: Int) {
    currentPageType = pages.element(at: index) ?? pages.first ?? .photoPage
  }
  
  func finish() {
    delegate?.onboardingViewModelDidFinish(self)
  }
  
  func close() {
    delegate?.onboardingViewModelDidRequestToClose(self)
  }
}
