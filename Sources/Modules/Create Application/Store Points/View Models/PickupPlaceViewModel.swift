//
//  PickupPlaceViewModel.swift
//  ForwardLeasing
//

import UIKit

struct PickupPlaceViewModel: PickupPlaceViewModelProtocol {
  let storePointInfo: StorePointInfo
  let pickupButtonTitle: String
  let onDidTapClose: (() -> Void)?
  let onDidTapPickup: (() -> Void)?
}
