//
//  DeliveryCheckPaymentViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

protocol CheckPaymentViewModelDelegate: class {
  func checkPaymentViewModelDidFinishSuccess(_ viewModel: CheckPaymentViewModel)
  func checkPaymentViewModelDidRequestCheckLater(_ viewModel: CheckPaymentViewModel)
  func checkPaymentViewModelDidCancelDelivery(_ viewModel: CheckPaymentViewModel)
  func checkPaymentViewModel(_ viewModel: CheckPaymentViewModel,
                             didRequestRepeatPaymentWithURL url: URL)
}

class CheckPaymentViewModel {
  // MARK: - Types
  typealias Dependencies = HasDeliveryService
  
  // MARK: - Properties
  weak var delegate: CheckPaymentViewModelDelegate?
  
  var onDidReceivePaymentError: (() -> Void)?
  var onDidStartTimer: (() -> Void)?
  var onDidCancelAlert: (() -> Void)?
  
  private(set) lazy var timerViewModel = makeTimerViewModel()
  private(set) lazy var deliveryPaymentFailedViewModel = makeDeliveryPaymentFailedViewModel()
  private(set) lazy var cancelDeliveryAlertActions = makeCancelAlertActions()
  
  private let dependencies: Dependencies
  
  private let promiseRetrier = PromiseRetrier()
  private let application: LeasingEntity
  private let isPaymentFailed: Bool
  
  // MARK: - Init
  init(dependencies: Dependencies,
       application: LeasingEntity,
       isPaymentFailed: Bool) {
    self.dependencies = dependencies
    self.application = application
    self.isPaymentFailed = isPaymentFailed
  }
  
  // MARK: - Public
  func startTimer() {
    guard !isPaymentFailed else {
      onDidReceivePaymentError?()
      return
    }
    timerViewModel.startTimer()
    onDidStartTimer?()
  }
  
  func checkPayment() {
    guard !isPaymentFailed else {
      onDidReceivePaymentError?()
      return
    }
    firstly {
      promiseRetrier.retry(times: 6, cooldown: 10, shouldFail: { error in
        if let error = error as? CheckPaymentError {
          return error != .pending
        } else {
          return true
        }
      }, body: checkPaymentRequestBody())
    }.catch { error in
      self.handle(error)
    }
  }
    
  // MARK: - Private Methods
  private func cancelDelivery() {
   firstly {
     dependencies.deliveryService.cancelDelivery(applicationID: application.applicationID)
   }.done { _ in
     self.delegate?.checkPaymentViewModelDidCancelDelivery(self)
   }.catch { _ in
     self.onDidReceivePaymentError?()
   }
  }
  
  private func repeatPay() {
    firstly {
      dependencies.deliveryService.pay(applicationID: application.applicationID, isCancelPrevious: true)
    }.done { response in
      self.handle(response)
    }.catch { _ in
      self.onDidReceivePaymentError?()
    }
  }
  
  private func checkPaymentRequestBody() -> (() -> Promise<CheckPaymentResponse>) {
    return { [unowned self] in
      return self.makeCheckPaymentRequest()
    }
  }
  
  private func makeCheckPaymentRequest() -> Promise<CheckPaymentResponse> {
    return Promise { seal in
      firstly {
        dependencies.deliveryService.checkPayment(applicationID: application.applicationID)
      }.then { response -> Promise<CheckPaymentResponse> in
        return self.handle(response)
      }.done { response in
        seal.fulfill(response)
      }.catch { error in
        seal.reject(error)
      }
    }
  }

  private func handle(_ response: CheckPaymentResponse) -> Promise<CheckPaymentResponse> {
    switch response.status {
    case .ok:
      defer {
        delegate?.checkPaymentViewModelDidFinishSuccess(self)
      }
      return Promise.value(response)
    case .pending:
      return Promise(error: CheckPaymentError.pending)
    case .error:
      timerViewModel.stopTimer()
      return Promise(error: CheckPaymentError.notConfirmedPayment)
    }
  }
  
  private func handle(_ response: PaymentResponse) {
    delegate?.checkPaymentViewModel(self, didRequestRepeatPaymentWithURL: response.paymentURL)
  }
  
  private func handle(_ error: Error) {
    if !(error is RetrierError) {
      self.onDidReceivePaymentError?()
    }
  }
  
  private func makeTimerViewModel() -> TimerViewModel {
    let timerViewModel = TimerViewModel(title: R.string.deliveryProduct.checkDeliveryPaymentTimerTitle(),
                                        subtitle: R.string.deliveryProduct.checkDeliveryPaymentTimerSubtitle())
    timerViewModel.delegate = self
    return timerViewModel
  }
  
  private func makeDeliveryPaymentFailedViewModel() -> DeliveryPaymentFailedViewModel {
    return DeliveryPaymentFailedViewModel(onDidTapRepeat: { [weak self] in
      self?.repeatPay()
    }, onDidTapCheckLater: { [weak self] in
      guard let self = self else { return }
      self.delegate?.checkPaymentViewModelDidRequestCheckLater(self)
    }, onDidTapCancel: { [weak self] in
      self?.onDidCancelAlert?()
    })
  }
  
  private func makeCancelAlertActions() -> [AlertAction] {
    let okAction = AlertAction(title: R.string.common.yes(), buttonType: .primary) { [weak self] in
      self?.cancelDelivery()
    }
    let cancelAction = AlertAction(title: R.string.common.cancel(), buttonType: .secondary, action: nil)
    return [okAction, cancelAction]
  }
}

// MARK: - TimerViewModelDelegate
extension CheckPaymentViewModel: TimerViewModelDelegate {
  func timerViewModelDidFinish(_ viewModel: TimerViewModel) {
    onDidReceivePaymentError?()
  }
}
