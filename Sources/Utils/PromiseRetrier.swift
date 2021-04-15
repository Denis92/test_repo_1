//
//  PromiseRetrier.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

enum RetrierError: Error {
  case cancel
  case tooManyAttempts
}

class PromiseRetrier {
  // MARK: - Properties
  private var isCanceled = false
  
  // MARK: - Retry
  func retry<T>(times: Int = 0, cooldown: TimeInterval, shouldFail: ((Error) -> Bool)? = nil,
                body: @escaping () -> Promise<T>) -> Promise<T> {
    var retryCounter = 0
    func attempt() -> Promise<T> {
      return body().recover(policy: CatchPolicy.allErrorsExceptCancellation) { error -> Promise<T> in
        retryCounter += 1
        guard !self.isCanceled else {
          self.isCanceled = false
          throw RetrierError.cancel
        }
        if times > 0 {
          guard retryCounter <= times  else {
            throw RetrierError.tooManyAttempts
          }
        }
        if retryCounter == times {
          guard !(shouldFail?(error) ?? false) else {
            throw error
          }
        }
        return after(seconds: cooldown).then(attempt)
      }
    }
    return attempt()
  }
  
  // MARK: - Cancel
  func cancel() {
    isCanceled = true
  }
}
