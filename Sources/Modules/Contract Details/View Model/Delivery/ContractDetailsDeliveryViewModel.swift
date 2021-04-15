//
//  ContractDetailsDeliveryViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

protocol ContractDetailsDeliveryViewModelDelegate: class {
  func contractDetailsDeliveryViewModelDidCancelDelivery(_ viewModel: ContractDetailsDeliveryViewModel)
  func contractDetailsDeliveryViewModel(_ viewModel: ContractDetailsDeliveryViewModel,
                                        didReceiveError error: Error)
}

class ContractDetailsDeliveryViewModel: CommonTableCellViewModel, ContractDetailsDeliveryViewModelProtocol {
  var tableCellIdentifier: String {
    return ContractDetailsDeliveryCell.reuseIdentifier
  }
  
  typealias Dependencies = HasDeliveryService 
  
  // MARK: - Properties
  var onDidTapCancelDelivery: (() -> Void)?
  var onDidStartCancelRequest: (() -> Void)?
  var onDidFinishCancelRequest: (() -> Void)?
  
  let shouldShowStatusOfDelivery: Bool
  
  weak var delegate: ContractDetailsDeliveryViewModelDelegate?
  
  private(set) lazy var statusOfDeliveryViewModel = makeStatusOfDeliveryViewModel()
  private let leasingEntity: LeasingEntity
  private let dayMonthFormatter = DateFormatter.dayMonthDisplayable
  private let timeFormatter = DateFormatter.timeOnlyDisplayable
  
  private let dependencies: Dependencies
      
  // MARK: - Init
  init(dependencies: Dependencies, leasingEntity: LeasingEntity,
       shouldShowStatusOfDelivery: Bool) {
    self.leasingEntity = leasingEntity
    self.dependencies = dependencies
    self.shouldShowStatusOfDelivery = shouldShowStatusOfDelivery
    onDidTapCancelDelivery = { [weak self] in
      self?.cancelDelivery()
    }
  }
  
  // MARK: - Private
  private func cancelDelivery() {
    onDidStartCancelRequest?()
    firstly {
      dependencies.deliveryService.cancelDelivery(applicationID: leasingEntity.applicationID)
    }.ensure {
      self.onDidFinishCancelRequest?()
    }.done { _ in
      self.delegate?.contractDetailsDeliveryViewModelDidCancelDelivery(self)
    }.catch { error in
      self.delegate?.contractDetailsDeliveryViewModel(self, didReceiveError: error)
    }
  }
  
  private func makeStatusOfDeliveryViewModel() -> StatusOfDeliveryViewModel {
    let deliverySteps: [DeliveryStatus] = [.new, .shipped, .delivering, .delivered]
    
    guard let deliveryHistory = leasingEntity.contractActionInfo?.deliveryHistory else {
      return StatusOfDeliveryViewModel(statusItems: [])
    }

    let items = deliverySteps.map { step -> DeliveryStatusItemViewModel in
      let deliveryItem = deliveryHistory.first { $0.deliveryStatus == step }
      let statusTitle = ContractDeliveryStatusAsset.title(for: step)
      let date: String?
      let time: String?
      
      if let deliveryDate = deliveryItem?.createDate {
        date = dayMonthFormatter.string(from: deliveryDate)
        time = timeFormatter.string(from: deliveryDate)
      } else {
        date = nil
        time = nil
      }
      
      return DeliveryStatusItemViewModel(isFinished: deliveryItem != nil,
                                         status: statusTitle,
                                         date: date, time: time)
    }

    return StatusOfDeliveryViewModel(statusItems: items)
  }
 }
