//
//  LeasingEntity.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let hardcheckerApprovedCode = "APPROVED"
}

enum EntityType {
  case application
  case contract
}

struct LeasingEntity: Codable {
  enum CodingKeys: String, CodingKey {
    case applicationID, createDate, expirationDate, type, status, hasSelfieImage,
         hasPassportImage, passportSelfieStatus, partnerID = "partnerId",
         previousApplicationID = "previousApplicationId", previousContractNumber, productInfo,
         email, basketID = "basketId", mobilePhoneMasked, agentID = "agentId",
         hasPersonalDataExist, hardCheckCode, hardCheckText, productImage = "goodImage", clientInfoMasked,
         clientImages, contractActionInfo, statusTitle, contractInfo,
         additionalServicesInfo, contractNumber, deliveryType, statusDescription,
         clientPersonalData, printDocuments
  }
  
  enum AdditionalKeys: String, CodingKey {
    case applicationIDLowercased = "applicationId", applicationType, applicationInfo, clientInfo,
         paymentSchedule, upgradeApplicationID = "upgradeApplicationId"
  }
  
  let applicationID: String
  let contractNumber: String?
  let createDate: Date
  let expirationDate: Date?
  let type: LeasingApplicationType
  let status: LeasingEntityStatus
  let statusTitle: String?
  let statusDescription: String?
  let hasSelfieImage: Bool
  let hasPassportImage: Bool
  let passportSelfieStatus: PassportSelfieStatus?
  let partnerID: String?
  let previousApplicationID: String?
  let previousContractNumber: String?
  let productInfo: LeasingProductInfo
  let basketID: String?
  let email: String?
  let mobilePhoneMasked: String?
  let agentID: String?
  let hasPersonalDataExist: Bool
  let hardCheckCode: String?
  let hardCheckText: String?
  let clientInfoMasked: ClientInfo?
  let clientImages: [ClientImage]
  let contractInfo: LeasingContractInfo?
  let contractActionInfo: ContractActionInfo?
  let additionalServicesInfo: [ProductAdditionalService]
  let deliveryType: DeliveryType?
  let clientPersonalData: ClientPersonalData?
  let upgradeApplicationId: String?
  var printDocuments: [PrintDocument]
  
  var productImageURL: URL? {
    guard let productImage = productImage else {
      return nil
    }
    return URL(string: productImage)
  }
  var productImage: String?
  
  var isContract: Bool {
    return contractNumber != nil
  }
  
  var entityType: EntityType {
    return contractNumber == nil ? .application : .contract
  }
  
  var hasHardcheckerError: Bool {
    if let code = hardCheckCode, code != Constants.hardcheckerApprovedCode {
      return true
    } else {
      return false
    }
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let additionalContainer = try decoder.container(keyedBy: AdditionalKeys.self)
    if let applicationID = try container.decodeIfPresent(String.self, forKey: .applicationID) {
      self.applicationID = applicationID
    } else {
      applicationID = try additionalContainer.decode(String.self, forKey: .applicationIDLowercased)
    }
    createDate = try container.decode(Date.self, forKey: .createDate)
    if let type = try container.decodeIfPresent(LeasingApplicationType.self, forKey: .type) {
      self.type = type
    } else {
      type = try additionalContainer.decode(LeasingApplicationType.self, forKey: .applicationType)
    }
    status = (try? container.decode(LeasingEntityStatus.self, forKey: .status)) ?? .unknown
    productImage = try container.decodeIfPresent(String.self, forKey: .productImage)
    if let applicationInfo = try additionalContainer.decodeIfPresent(ApplicationInfo.self,
                                                                     forKey: .applicationInfo) {
      expirationDate = applicationInfo.expirationDate
      hasSelfieImage = applicationInfo.hasSelfieImage
      hasPassportImage = applicationInfo.hasPassportImage
    } else {
      expirationDate = try container.decodeIfPresent(Date.self, forKey: .expirationDate)
      hasSelfieImage = try container.decodeIfPresent(Bool.self, forKey: .hasSelfieImage) ?? false
      hasPassportImage = try container.decodeIfPresent(Bool.self, forKey: .hasPassportImage) ?? false
    }
    passportSelfieStatus = try? container.decodeIfPresent(PassportSelfieStatus.self, forKey: .passportSelfieStatus)
    partnerID = try container.decodeIfPresent(String.self, forKey: .partnerID)
    previousApplicationID = try container.decodeIfPresent(String.self, forKey: .previousApplicationID)
    previousContractNumber = try container.decodeIfPresent(String.self, forKey: .previousContractNumber)
    productInfo = try container.decode(LeasingProductInfo.self, forKey: .productInfo)
    basketID = try container.decodeIfPresent(String.self, forKey: .basketID)
    agentID = try container.decodeIfPresent(String.self, forKey: .agentID)
    hasPersonalDataExist = try container.decodeIfPresent(Bool.self,
                                                         forKey: .hasPersonalDataExist) ?? false
    hardCheckCode = try container.decodeIfPresent(String.self, forKey: .hardCheckCode)
    hardCheckText = try container.decodeIfPresent(String.self, forKey: .hardCheckText)
    clientInfoMasked = try container.decodeIfPresent(ClientInfo.self, forKey: .clientInfoMasked)
    clientImages = try container.decodeIfPresent([ClientImage].self, forKey: .clientImages) ?? []
    if let clientInfo = try additionalContainer.decodeIfPresent(ShortClientInfo.self, forKey: .clientInfo) {
      email = clientInfo.email
      mobilePhoneMasked = clientInfo.mobilePhoneMasked
    } else {
      email = try container.decodeIfPresent(String.self, forKey: .email)
      mobilePhoneMasked = try container.decodeIfPresent(String.self, forKey: .mobilePhoneMasked)
    }
    contractActionInfo = try container.decodeIfPresent(ContractActionInfo.self, forKey: .contractActionInfo)
    statusTitle = try container.decodeIfPresent(String.self, forKey: .statusTitle)
    statusDescription = try container.decodeIfPresent(String.self, forKey: .statusDescription)
    contractInfo = try container.decodeIfPresent(LeasingContractInfo.self, forKey: .contractInfo)
    additionalServicesInfo = try container.decodeIfPresent([ProductAdditionalService].self,
                                                           forKey: .additionalServicesInfo) ?? []
    contractNumber = try container.decodeIfPresent(String.self, forKey: .contractNumber)
    deliveryType = try container.decodeIfPresent(DeliveryType.self, forKey: .deliveryType)
    clientPersonalData = try container.decodeIfPresent(ClientPersonalData.self, forKey: .clientPersonalData)
    upgradeApplicationId = try additionalContainer.decodeIfPresent(String.self, forKey: .upgradeApplicationID)
    printDocuments = try container.decodeIfPresent([PrintDocument].self, forKey: .printDocuments) ?? []
  }
}

enum ImageType: String, Codable {
  case selfie = "SELFIE", passport = "PASSPORT_RECOGNIZE"
}

struct ClientImage: Codable {
  enum CodingKeys: String, CodingKey {
    case imageType, imageURL = "imageUrl"
  }
  
  let imageType: ImageType
  let imageURL: String
}

struct PrintDocument: Codable {
  let name: String?
  let link: String?
  
  var documentURL: URL? {
    guard let link = link else { return nil }
    return URL(string: URLFactory.Cabinet.printDocument(link: link))
  }
}

extension LeasingEntity: Equatable {
  static func == (lhs: LeasingEntity, rhs: LeasingEntity) -> Bool {
    return lhs.applicationID == rhs.applicationID
  }
}

private struct ApplicationInfo: Decodable {
  let hasSelfieImage: Bool
  let hasPassportImage: Bool
  let expirationDate: Date?
}
