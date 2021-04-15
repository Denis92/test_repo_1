//
//  ProfileCellViewModelsDelegate.swift
//  ForwardLeasing
//

import Foundation

enum ProfileCellAction {
  case selectSegment(ProfileSegment)
  case leasingEntityAction(_ buttonAction: ProductButtonAction, _ leasingEntity: LeasingEntity)
  case subscriptionAction(_ buttonAction: ProductButtonAction, _ subscription: BoughtSubscription)
  case selectLeasingEntity(_ leasingEntity: LeasingEntity)
  case selectSubscription(_ subscription: BoughtSubscription)
  case hideSubscription(_ subscription: BoughtSubscription)
}

protocol ProfileCellViewModelsDelegate: class {
  func cellViewModel(_ cellViewModel: CommonTableCellViewModel, didSelect action: ProfileCellAction)
}
