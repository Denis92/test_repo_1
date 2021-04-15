//
//  LeasingEntityStatus.swift
//  ForwardLeasing
//

import Foundation

enum LeasingEntityStatus: String, Codable {
  case draft = "DRAFT"
  case confirmed = "CONFIRMED"
  case dataSaved = "DATA_SAVED"
  case pending = "PENDING"
  case inReview = "IN_REVIEW"
  case rejected = "REJECTED"
  case approved = "APPROVED"
  case error = "ERROR"
  case cancelled = "CANCEL"
  case signSmsSend = "SIGN_SMS_SEND"
  case signed = "SIGNED"
  case contractInit = "CONTRACT_INIT"
  case contractCreated = "CONTRACT_CREATED"
  case contractCanceled = "CONTRACT_CANCELED"
  case actSigned = "ACT_SIGNED"
  case inBackoffice = "IN_BACKOFFICE"
  case returnCreated = "RETURN_CREATED"
  case upgradeCreated = "UPGRADE_CREATED"
  case tradeInImpossible = "TRADEIN_IMPOSSIBLE"
  case closed = "CLOSED"
  case deliveryStarted = "DELIVERY_STARTED"
  case deliveryCreated = "DELIVERY_CREATED"
  case deliveryShipped = "DELIVERY_SHIPPED"
  case deliveryCompleted = "DELIVERY_COMPLETED"
  case unknown
  
  var isInBackoffice: Bool {
    return self == .inBackoffice
  }
}
