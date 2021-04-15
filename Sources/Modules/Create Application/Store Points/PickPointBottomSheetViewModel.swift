//
//  PickPointBottomSheetViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol PickPointBottomSheetViewModelDelegate: class {
  func pickPointBottomSheetViewModel(_ viewModel: PickPointBottomSheetViewModel,
                                     didSelectPoint point: StorePointInfo)
  func pickPointBottomSheetViewModelDidRequestClose(_ viewModel: PickPointBottomSheetViewModel)
}

class PickPointBottomSheetViewModel {
  // MARK: - Properties
  var onDidUpdate: (() -> Void)?
  
  weak var delegate: PickPointBottomSheetViewModelDelegate?
  
  private(set) lazy var pickupPlaceViewModel = makePickupPlaceViewModel()
  private var point: StorePointInfo
  private let pickupButtonTitleStrategy: PickupButtonTitleStrategy
  
  // MARK: - Init
  init(storePoint: StorePointInfo, pickupButtonTitleStrategy: PickupButtonTitleStrategy) {
    self.point = storePoint
    self.pickupButtonTitleStrategy = pickupButtonTitleStrategy
  }
  
  // MARK: - Public
  func update(point: StorePointInfo) {
    self.point = point
    self.pickupPlaceViewModel = makePickupPlaceViewModel()
    onDidUpdate?()
  }

  // MARK: - Private
  private func makePickupPlaceViewModel() -> PickupPlaceViewModel {
    let viewModel = PickupPlaceViewModel(storePointInfo: point,
                                         pickupButtonTitle: pickupButtonTitleStrategy.title,
                                         onDidTapClose: { [weak self] in
                                          guard let self = self else { return }
                                          self.delegate?.pickPointBottomSheetViewModelDidRequestClose(self)
                                         }, onDidTapPickup: { [weak self] in
                                          guard let self = self else { return }
                                          self.delegate?.pickPointBottomSheetViewModel(self,
                                                                                       didSelectPoint: self.point)
                                         })
    return viewModel
  }
}
