//
//  ContractActionInfo.swift
//  ForwardLeasing
//

import Foundation

enum DiagnosticType: String, Codable {
  case swGroup = "SWGROUP", forward = "FORWARD", manual = "MANUAL"
}

struct ContractActionInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case deliveryInfo, storePoint, deliveryHistory, diagnosticType, checkSessionID = "checkSessionId",
         checkSessionURL = "checkSessionUrl", upgradeReturnPaymentSum, upgradeReturnSumPaid, actExpirationDate
  }
  
  let deliveryInfo: DeliveryInfo?
  let storePoint: StorePointInfo?
  let deliveryHistory: [DeliveryHistoryItem]
  let diagnosticType: DiagnosticType?
  let checkSessionID: String?
  let checkSessionURL: String?
  let upgradeReturnPaymentSum: Decimal?
  let upgradeReturnSumPaid: Bool?
  let actExpirationDate: Date?
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    deliveryInfo = try container.decodeIfPresent(DeliveryInfo.self, forKey: .deliveryInfo)
    storePoint = try container.decodeIfPresent(StorePointInfo.self, forKey: .storePoint)
    deliveryHistory = try container.decodeIfPresent([DeliveryHistoryItem].self, forKey: .deliveryHistory) ?? []
    diagnosticType = try container.decodeIfPresent(DiagnosticType.self, forKey: .diagnosticType)
    checkSessionID = try container.decodeIfPresent(String.self, forKey: .checkSessionID)
    checkSessionURL = try container.decodeIfPresent(String.self, forKey: .checkSessionURL)
    upgradeReturnPaymentSum = try container.decodeIfPresent(Decimal.self, forKey: .upgradeReturnPaymentSum)
    upgradeReturnSumPaid = try container.decodeIfPresent(Bool.self, forKey: .upgradeReturnSumPaid)
    actExpirationDate = try container.decodeIfPresent(Date.self, forKey: .actExpirationDate)
  }
}
