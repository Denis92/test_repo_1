//
//  TimerViewModel.swift
//  ForwardLeasing
//

import Foundation
import CoreGraphics

private extension Constants {
  static let totalTime: TimeInterval = 60
}

protocol TimerViewModelDelegate: class {
  func timerViewModelDidFinish(_ viewModel: TimerViewModel)
}

class TimerViewModel {
  weak var delegate: TimerViewModelDelegate?
  
  // MARK: - Properties
  var totalTimeFormattedString: String {
    return totalTime.timerString()
  }
  
  var fraction: CGFloat {
    return CGFloat(totalTime / Constants.totalTime)
  }
  
  var isActive: Bool {
    return countdownTimer != nil
  }
  
  var onDidCountdownUpdate: (() -> Void)?
  
  let title: String
  let subtitle: String
  
  private var countdownTimer: Timer?
  private var totalTime = Constants.totalTime
  
  // MARK: - Init
  init(title: String, subtitle: String) {
    self.title = title
    self.subtitle = subtitle
  }
  
  // MARK: - Methods
  func startTimer() {
    totalTime = Constants.totalTime
    countdownTimer = Timer.scheduledTimer(timeInterval: 1,
                                          target: self,
                                          selector: #selector(updateTime),
                                          userInfo: nil,
                                          repeats: true)
    onDidCountdownUpdate?()
  }
  
  func stopTimer() {
    countdownTimer?.invalidate()
    countdownTimer = nil
  }

  @objc private func updateTime() {
    if totalTime != 0 {
      totalTime -= 1
    } else {
      stopTimer()
      delegate?.timerViewModelDidFinish(self)
    }
    onDidCountdownUpdate?()
  }
}
