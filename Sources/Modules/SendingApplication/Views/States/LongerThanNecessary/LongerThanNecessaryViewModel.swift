//
//  LongerThanNecessaryViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol LongerThanNecessaryViewModelDelegate: class {
  func longerThanNecessaryViewModelDidTapCheckLater(_ viewModel: LongerThanNecessaryViewModel)
  func longerThanNecessaryViewModelDidTapCancel(_ viewModel: LongerThanNecessaryViewModel)
}

private extension Constants {
  static let almostDoneThreshold: TimeInterval = 15
}

class LongerThanNecessaryViewModel {
  // MARK: - Properties
  var title: String {
    return isAlmostDone ?
      R.string.sendingApplication.almostDoneViewTitle() :
      R.string.sendingApplication.longerThanNecessaryViewTitle()
  }
  
  var subtitle: String {
    return isAlmostDone ?
      R.string.sendingApplication.almostDoneViewSubTitle() :
      R.string.sendingApplication.longerThanNecessaryViewSubTitle()
  }
  
  var onDidUpdate: (() -> Void)?
  
  weak var delegate: LongerThanNecessaryViewModelDelegate?
  var onDidHiddenButtons: (() -> Void)?
  var isActive = false
  
  private(set) var isAlmostDone: Bool = true
  
  func start() {
    self.isActive = true
    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.almostDoneThreshold) {
      self.isAlmostDone = false
      self.onDidUpdate?()
    }
  }
  
  func didTapCheckLater() {
    delegate?.longerThanNecessaryViewModelDidTapCheckLater(self)
  }
  
  func didTapCancel() {
    delegate?.longerThanNecessaryViewModelDidTapCancel(self)
  }
}
