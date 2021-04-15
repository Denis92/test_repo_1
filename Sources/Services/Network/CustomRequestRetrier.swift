//
//  CustomRequestRetrier.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit
import Alamofire

protocol SessionRefreshing: class {
  func refreshSession() -> Promise<Void>
  var isRefreshingSession: Bool { get }
}

class CustomRequestRetrier: Retrier {
  private let lock = NSLock()
  private var requestsToRetry: [(RetryResult) -> Void] = []
  
  var onNeedsToRefreshSession: (() -> SessionRefreshing?)?
  
  init() {
    super.init { _, _, _, completion in completion(.doNotRetry) }
  }
  
  override func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    lock.lock()
    defer { lock.unlock() }

    guard NetworkErrorService.isUnauthorizedError(error) else {
      completion(.doNotRetry)
      return
    }
    
    guard let sessionRefresher = onNeedsToRefreshSession?() else {
      completion(.doNotRetryWithError(TokenRefreshError.refreshNotPossible))
      return
    }
    
    requestsToRetry.append(completion)
    
    guard sessionRefresher.isRefreshingSession != true else { return }
    
    firstly {
      sessionRefresher.refreshSession()
    }.done { _ in
      self.lock.lock()
      defer { self.lock.unlock() }
  
      self.requestsToRetry.forEach { $0(.retry) }
      self.requestsToRetry.removeAll()
    }.catch { _ in
      self.requestsToRetry.forEach { $0(.doNotRetryWithError(error)) }
      self.requestsToRetry.removeAll()
      completion(.doNotRetryWithError(error))
    }
  }
}
