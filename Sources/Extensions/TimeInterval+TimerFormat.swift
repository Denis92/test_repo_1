//
//  TimeInterval+TimerFormat.swift
//  ForwardLeasing
//

import Foundation

extension TimeInterval {
  func timerString() -> String {
    let seconds: Int = Int(self) % 60
    let minutes: Int = (Int(self) / 60) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}
