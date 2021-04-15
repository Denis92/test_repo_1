//
//  PaymentRegistrationViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol PaymentRegistrationViewModelDelegate: class {
  func paymentRegistrationViewModelDidCancel(_ viewModel: PaymentRegistrationViewModel)
  func paymentRegistrationViewModel(_ viewModel: PaymentRegistrationViewModel,
                                    didFinishWithPaymentURL paymentURL: URL)
}

private struct PaymentScheduleDecorator {
  let paymentNumber: Int
  let paymentSchedule: PaymentScheduleItem
  let sumWithPrevPeriods: Amount
}

private class Period {
  let plannedPaymentDate: Date
  let payments: [PaymentScheduleDecorator]
  var sum: Amount {
    return payments.reduce(0) {
      return $0 + Amount(decimal: $1.paymentSchedule.paymentAmount)
    }
  }
  let overdueSum: Amount
  var totalSum: Amount {
    return sum + overdueSum
  }
  var totalSumWithPrevPeriods: Amount {
    return payments.reduce(0) {
      return $0 + $1.sumWithPrevPeriods
    }
  }
  var paymentNumber: String {
    guard let number = payments.first?.paymentNumber else { return "" }
    return "\(number)"
  }

  init(plannedPaymentDate: Date, payments: [PaymentScheduleDecorator],
       overdueSum: Amount) {
    self.plannedPaymentDate = plannedPaymentDate
    self.payments = payments
    self.overdueSum = overdueSum
  }
}

class PaymentRegistrationViewModel: CommonCollectionViewModel {
  typealias Dependencies = HasCardsService & HasPaymentsService

  struct Output {
    let id: String
    let url: URL
    let reference: String
  }
  // MARK: - Properties

  weak var delegate: PaymentRegistrationViewModelDelegate?

  var title: String {
    return R.string.paymentRegistration.title()
  }
  var plannedPaymentDate: String? {
    guard let plannedPaymentDate = selectedPeriods.last?.plannedPaymentDate else {
      return nil
    }
    return R.string.paymentRegistration.toDate(dateFormatter.string(from: plannedPaymentDate))
  }
  var payButtonTitle: String {
    let sum = selectedPeriods.reduce(0) {
      $0 + $1.totalSum
    }
    let sumString = currencyFormatter.string(from: sum) ?? ""
    return R.string.paymentRegistration.paySum(sumString)
  }
  private(set) var paymentDetails: String?
  let cardsViewModel: PaymentCardPickerViewModel

  var collectionCellViewModels: [CommonCollectionCellViewModel] = []

  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?
  var onDidUpdateSelectedPeriods: (() -> Void)?
  var onDidStartUpdateCards: (() -> Void)?
  var onDidFinishUpdateCards: (() -> Void)?
  var onDidReceiveWrongMinimumPayment: ((String) -> Void)?
  
  private let dependencies: Dependencies
  private let dateFormatter: DateFormatter = .dayMonthDisplayable
  private let currencyFormatter: NumberFormatter = .currencyFormatter(withSymbol: true)
  private let dateIntervalFormatter: DateIntervalFormatter = .fullMonthOnlyInterval

  private let contract: LeasingEntity
  private var notPaidPeriods: [Period] = []
  private var selectedPeriods: [Period] = []

  // MARK: - Init

  init(contract: LeasingEntity,
       dependencies: Dependencies) {
    self.contract = contract
    self.dependencies = dependencies
    self.cardsViewModel = PaymentCardPickerViewModel(dependences: dependencies)

    cardsViewModel.delegate = self
    makeNotPaidPeriods()
    makeCellViewModels()
    if let period = notPaidPeriods.first {
      selectedPeriods.append(period)
    }
    updatePaymentDetails()
  }

  // MARK: - Public methods

  func pay() {
    onDidStartRequest?()
    firstly {
      dependencies.paymentsService.pay(paymentInfo: getPaymentInfo())
    }.done { response in
      self.delegate?.paymentRegistrationViewModel(self, didFinishWithPaymentURL: response.paymentInfo.paymentURL)
    }.catch { error in
      self.onDidReceiveError?(error)
    }.finally {
      self.onDidFinishRequest?()
    }
  }

  func cancel() {
    delegate?.paymentRegistrationViewModelDidCancel(self)
  }

  func requestCards() {
    cardsViewModel.requestCards()
  }

  func selectPeriod(atIndex index: Int) {
    guard index >= 0, notPaidPeriods.count > index else { return }
    selectedPeriods = Array(notPaidPeriods[...index])
    updatePaymentDetails()
    onDidUpdateSelectedPeriods?()
  }

  // MARK: - Private methods

  private func updatePaymentDetails() {
    guard let firstPeriod = selectedPeriods.first else {
      paymentDetails = nil
      return
    }
    var details = currencyFormatter.string(from: firstPeriod.sum) ?? ""
    if selectedPeriods.count > 1 {
      if selectedPeriods.count == 2,
        let secondPayment = selectedPeriods.element(at: 1) {
        let period = R.string.paymentRegistration.payForTwoMonths(firstPeriod.plannedPaymentDate.fullStandAloneMonth,
                                                                  secondPayment.plannedPaymentDate.fullStandAloneMonth)
        details += " \(period)"
      } else if let lastPayment = selectedPeriods.last {
        let period = R.string.paymentRegistration.paymentsOn(lastPayment.plannedPaymentDate.fullStandAloneMonth)
        details += " + \(period)"
      }
    }
    let overdueSum: Amount = selectedPeriods.reduce(0) {
      $0 + $1.overdueSum
    }

    if !overdueSum.isZero {
      details += " + \(R.string.paymentRegistration.totalOverdueSum(overdueSum.value.intValue))"
    }
    paymentDetails = details
  }

  private func makeNotPaidPeriods() {
    let overdueSum = contract.contractInfo?.overduePenalty ?? 0
    var sum = Amount(decimal: overdueSum)
    let paymentSchedule = contract.contractInfo?.paymentSchedule ?? []
    let paymentSchedules = paymentSchedule.enumerated().map { offset, schedule -> PaymentScheduleDecorator in
      let status = schedule.status(for: contract.contractInfo?.nextPaymentDate)
      if status != .paid {
        sum += Amount(decimal: schedule.paymentAmount)
      }
      return PaymentScheduleDecorator(paymentNumber: offset + 1, paymentSchedule: schedule,
                                      sumWithPrevPeriods: sum)
    }
    let periodsInfo: [Date: [PaymentScheduleDecorator]] = paymentSchedules.reduce([:]) {
      var result = $0
      let status = $1.paymentSchedule.status(for: contract.contractInfo?.nextPaymentDate)
      if status != .paid,
         let date = $1.paymentSchedule.paymentDueDate.dateOnly {
        result[date, default: []].append($1)
      }
      return result
    }
    notPaidPeriods = periodsInfo
      .map { Period(plannedPaymentDate: $0.key, payments: $0.value, overdueSum: Amount(decimal: overdueSum)) }
      .sorted { $0.plannedPaymentDate < $1.plannedPaymentDate }
  }

  private func makeCellViewModels() {
    var viewModels: [CommonCollectionCellViewModel] = []
    let firstPaymentNumber = notPaidPeriods.first?.paymentNumber ?? ""
    let firstPaymentDate = notPaidPeriods.first?.plannedPaymentDate
    notPaidPeriods.enumerated().forEach {
      var paymentNumbersInfo = R.string.paymentRegistration.paymentNumber()
      let dateString: String
      let month = $0.element.plannedPaymentDate.fullStandAloneMonth
      switch $0.offset {
      case 0:
        paymentNumbersInfo += $0.element.paymentNumber
        dateString = month.capitalized
      case 1:
        paymentNumbersInfo += "\(firstPaymentNumber),\($0.element.paymentNumber)"
        dateString = "\(firstPaymentDate?.fullStandAloneMonth.capitalized ?? "") + \(month)"
      default:
        paymentNumbersInfo += "\(firstPaymentNumber) - \($0.element.paymentNumber)"
        dateString = R.string.paymentRegistration.fromTo(firstPaymentDate?.fullMonth ?? "", month)
      }
      let sum = currencyFormatter.string(from: $0.element.totalSumWithPrevPeriods) ?? ""
      viewModels.append(PaymentPerionCellViewModel(dateString: dateString,
                                                   sumString: sum,
                                                   paymentInformation: paymentNumbersInfo))
    }
    collectionCellViewModels = viewModels
  }
  
  private func getPaymentInfo() -> PaymentInfo {
    let sumToPay = selectedPeriods.reduce(0) {
      $0 + $1.totalSum
    }.decimalValue
  
    switch cardsViewModel.selectedCard {
    case .new(let saveCardData):
      return PaymentInfo(contractNumber: contract.contractNumber ?? "",
                         paymentSum: sumToPay, cardID: nil,
                         shouldCreateTemplate: saveCardData)
    case .userCard(let card):
      return PaymentInfo(contractNumber: contract.contractNumber ?? "",
                         paymentSum: sumToPay, cardID: card.id,
                         shouldCreateTemplate: false)
    }
  }
}

// MARK: - PaymentCardPickerViewModelDelegate
extension PaymentRegistrationViewModel: PaymentCardPickerViewModelDelegate {
  func paymentCardPickerViewModel(_ viewModel: PaymentCardPickerViewModel, didReceiveError error: Error) {
    onDidReceiveError?(error)
  }

  func paymentCardPickerViewModel(_ viewModel: PaymentCardPickerViewModel,
                                  didSelectCard card: PaymentCardType) {}
  
  func paymentCardPickerViewModelOnDidStartRequest(_ viewModel: PaymentCardPickerViewModel) {
    onDidStartUpdateCards?()
  }
  
  func paymentCardPickerViewModelOnDidFinishRequest(_ viewModel: PaymentCardPickerViewModel) {
    onDidFinishUpdateCards?()
  }
}
