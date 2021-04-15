//
//  DeliveryInfo.swift
//  ForwardLeasing
//

import Foundation

enum DeliveryStatus: String, Codable {
  case none = "NONE"
  case draft = "DRAFT"
  case deliveryUnavailable = "DELIVERY_UNAVAILABLE"
  case goodUnavailable = "GOOD_UNAVAILABLE"
  case error = "ERROR"
  case new = "NEW"
  case shipped = "SHIPPED"
  case delivering = "DELIVERING"
  case lost = "LOST"
  case returning = "RETURNING"
  case delivered = "DELIVERED"
  case ok = "OK"
  
  var isNone: Bool {
    return self == .none
  }
}

enum DeliveryInfoStatus: String, Codable {
  case draft = "DL_DRAFT"
  case createPayment = "DL_CREATE_PAYMENT"
  case new = "DL_NEW"
  case created = "DL_CREATED"
  case signSmsSend = "DL_SIGN_SMS_SEND"
  case signed = "DL_SIGNED"
  case reserved = "DL_RESERVED"
  case shipped = "DL_SHIPPED"
  case complete = "DL_COMPLETE"
  case rejected = "DL_REJECTED"
  case canceled = "DL_CANCELED"
  case cancelPayment = "DL_CANCEL_PAYMENT"
  var isSigned: Bool {
    switch self {
    case .signed, .reserved, .shipped, .complete:
      return true
    case .draft, .createPayment, .new, .created, .signSmsSend, .rejected, .canceled, .cancelPayment:
      return false
    }
  }
}

struct DeliveryInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case deliveryStatus, status, addressString = "address", address = "addressJson",
         daysCount, postIndex, deliveryDate, cost
  }
  
  let deliveryStatus: DeliveryStatus?
  let status: DeliveryInfoStatus?
  let addressString: String
  let address: Address?
  let daysCount: Int?
  let postIndex: String?
  let deliveryDate: Date?
  let cost: Double
  
  // TODO: - remove
  init(deliveryStatus: DeliveryStatus?, addressString: String, address: Address?, daysCount: Int?,
       postIndex: String?, deliveryDate: Date?, cost: Double, status: DeliveryInfoStatus?) {
    self.deliveryStatus = deliveryStatus
    self.addressString = addressString
    self.address = address
    self.daysCount = daysCount
    self.postIndex = postIndex
    self.deliveryDate = deliveryDate
    self.cost = cost
    self.status = status
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    status = try container.decodeIfPresent(DeliveryInfoStatus.self, forKey: .status)
    deliveryStatus = try container.decodeIfPresent(DeliveryStatus.self, forKey: .deliveryStatus)
    addressString = try container.decode(String.self, forKey: .addressString)
    daysCount = try container.decodeIfPresent(Int.self, forKey: .daysCount)
    address = try container.decodeIfPresent(Address.self, forKey: .address)
    postIndex = try container.decodeIfPresent(String.self, forKey: .postIndex)
    deliveryDate = try container.decodeIfPresent(Date.self, forKey: .deliveryDate)
    cost = try container.decodeIfPresent(Double.self, forKey: .cost) ?? 0
  }
}
