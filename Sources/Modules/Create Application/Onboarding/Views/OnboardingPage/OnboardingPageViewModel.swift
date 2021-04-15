//
//  OnboardingPageViewModel.swift
//  ForwardLeasing
//

import UIKit.UIImage

enum OnboardingPageType: Int, CaseIterable {
  case photoPage, contractPage, deliveryPage, deviceStatePage, goToStorePage
  
  var title: String {
    switch self {
    case .photoPage:
      return R.string.onboarding.photoPage()
    case .contractPage:
      return R.string.onboarding.contractPage()
    case .deliveryPage:
      return R.string.onboarding.deliveryPage()
    case .deviceStatePage:
      return R.string.onboarding.deviceStatePage()
    case .goToStorePage:
      return R.string.onboarding.goToStorePage()
    }
  }
  
  var pageNumberImage: UIImage? {
    switch self {
    case .photoPage, .deviceStatePage:
      return R.image.onboardingPage1()
    case .contractPage, .goToStorePage:
      return R.image.onboardingPage2()
    case .deliveryPage:
      return R.image.onboardingPage3()
    }
  }
}

struct OnboardingPageViewModel {
  let title: String
  let pageNumberImage: UIImage?
}
