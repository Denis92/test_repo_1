//
//  SendingApplicationState.swift
//  ForwardLeasing
//

import Foundation

enum SendingApplicationState {
  case sending
  case timer
  case longerThanNecessary
  case notSent
  case approved
  case denied
  case isImpossible
}
