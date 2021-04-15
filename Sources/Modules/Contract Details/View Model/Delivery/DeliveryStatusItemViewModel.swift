//
//  DeliveryStatusItemViewModel.swift
//  ForwardLeasing
//

import UIKit

struct DeliveryStatusItemViewModel: DeliveryStatusItemViewModelProtocol {
  let isFinished: Bool
  let status: String?
  let date: String?
  let time: String?
}
