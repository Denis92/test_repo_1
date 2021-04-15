//
//  PhoneConfirmStrategyType.swift
//  ForwardLeasing
//

import Foundation

enum PhoneConfirmStrategyType {
  case leasingApplication(dependency: HasPersonalDataRegisterService,
                          leasingApplication: LeasingEntity)
  case tokenRefresh(dependency: HasPersonalDataRegisterService,
                    leasingApplication: LeasingEntity)
  case leasingContract(dependency: HasContractService,
                       leasingApplication: LeasingEntity)
  case signDelivery(dependency: HasDeliveryService,
                    leasingApplication: LeasingEntity)
  case pin(dependency: HasAuthService, sessionID: String,
           type: PinCodeConfirmationType)
  
  var isLeasingApplication: Bool {
    switch self {
    case .leasingApplication:
      return true
    default:
      return false
    }
  }
  
  var isTokenRefresh: Bool {
    switch self {
    case .tokenRefresh:
      return true
    default:
      return false
    }
  }
  
  var isLeasingContract: Bool {
    switch self {
    case .leasingContract:
      return true
    default:
      return false
    }
  }
  
  var isRegister: Bool {
    switch self {
    case .pin(_, _, let type):
      return type == .registration
    default:
      return false
    }
  }
  
  var isPinRecovery: Bool {
    switch self {
    case .pin(_, _, let type):
      return type == .pinRecovery
    default:
      return false
    }
  }

  var isSignDelivery: Bool {
    switch self {
    case .signDelivery:
      return true
    default:
      return false
    }
  }
  
  var strategy: PhoneConfirmationStrategy {
    switch self {
    case .leasingApplication(let dependency, let application):
      return ApplicationPhoneConfirmation(dependency: dependency, leasingApplication: application)
    case .tokenRefresh(let dependency, let application):
      return ApplicationTokenRefresh(dependency: dependency, leasingApplication: application)
    case .leasingContract(let dependency, let application):
      return ContractPhoneConfirmation(dependency: dependency, leasingApplication: application)
    case .pin(dependency: let dependency, _, let type):
      return PinCodeConfirmation(dependency: dependency, type: type)
    case .signDelivery(let dependency, let contract):
      return DeliveryPhoneConfirmation(dependency: dependency, contract: contract)
    }
  }
  
  var requestID: String {
    switch self {
    case .leasingApplication(_, let leasingApplication):
      return leasingApplication.applicationID
    case .tokenRefresh(_, let leasingApplication):
      return leasingApplication.applicationID
    case .leasingContract(_, let leasingApplication):
      return leasingApplication.applicationID
    case .pin(_, let sessionID, _):
      return sessionID
    case .signDelivery(_, let contract):
      return contract.applicationID
    }
  }
}
