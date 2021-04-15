//
//  LeasingEntityDataRefreshViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol LeasingEntityDataRefreshViewModelDelegate: class {
  func leasingEntityDataRefreshViewModel(_ viewModel: LeasingEntityDataRefreshViewModel, didRefresh leasingEntity: LeasingEntity)
  func leasingEntityDataRefreshViewModelDidFail(_ viewModel: LeasingEntityDataRefreshViewModel)
}

class LeasingEntityDataRefreshViewModel: DataRefreshViewModelProtocol {
  typealias Dependencies = HasApplicationService & HasContractService

  // MARK: - Properties
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?

  weak var delegate: LeasingEntityDataRefreshViewModelDelegate?

  private let dependencies: Dependencies
  private let leasingEntity: LeasingEntity

  // MARK: - Init
  init(dependencies: Dependencies,
       leasingEntity: LeasingEntity) {
    self.dependencies = dependencies
    self.leasingEntity = leasingEntity
  }

  // MARK: - Methods
  func refresh() {
    onDidStartRequest?()
    firstly {
      getLeasinEntityPromise()
    }.ensure {
      self.onDidFinishRequest?()
    }.done { leasingEntity in
      self.delegate?.leasingEntityDataRefreshViewModel(self,
                                                       didRefresh: leasingEntity)
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
      self.delegate?.leasingEntityDataRefreshViewModelDidFail(self)
    }
  }

  // MARK: - Private methods
  private func getLeasinEntityPromise() -> Promise<LeasingEntity> {
    return leasingEntity.entityType == .application
      ? dependencies.applicationService.getApplicationData(applicationID: leasingEntity.applicationID)
      : dependencies.contractService.getContract(applicationID: leasingEntity.applicationID,
                                                 useCache: false).map(\.clientLeasingEntity)
  }

}
