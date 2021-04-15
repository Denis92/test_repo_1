//
//  URLFactory.swift
//  ForwardLeasing
//

import Foundation

struct URLFactory {
  private static let baseRestURLString = NetworkEnvironment.current.baseRestURLString

  static func imageURL(imagePath: String) -> URL? {
    return URL(string: baseRestURLString + "\(imagePath)")
  }
  
  static func phoneNumber(phone: String) -> URL? {
    return URL(string: "tel://" + phone)
  }
  
  struct LeasingApplication {
    private static let baseV1URL = baseRestURLString + "/application/v1/leasing-application"
    private static let baseURL = baseRestURLString + "/application/v2/leasing-application"
    
    static var create: String {
      return baseURL
    }

    static func applicationData(applicationID: String) -> String {
      return baseURL + "/\(applicationID)" + "/leasing-application-data"
    }
    
    static func resendCode(applicationID: String) -> String {
      return baseURL + "/\(applicationID)" + "/resend-consents-otp"
    }
    
    static func sendCodeWhenRefreshingToken(applicationID: String) -> String {
      return baseURL + "/\(applicationID)" + "/continue-otp"
    }
    
    static func checkCodeWhenRefreshingToken(applicationID: String) -> String {
      return baseURL + "/\(applicationID)" + "/check-continue-otp"
    }
    
    static func checkCode(applicationID: String) -> String {
      return baseURL + "/\(applicationID)" + "/check-consents-otp"
    }

    static func checkStatus(applicationID: String) -> String {
      return baseURL + "/\(applicationID)" + "/leasing-application-short"
    }

    static func initiateScoring(applicationID: String) -> String {
      return baseURL + "/\(applicationID)" + "/review"
    }
    
    static func checkPhotos(applicationID: String) -> String {
      return baseV1URL + "/\(applicationID)" + "/check-passport-selfie"
    }

    static func clientData(applicationID: String) -> String {
      return baseURL + "/\(applicationID)" + "/client-data"
    }

    static func cancel(applicationID: String) -> String {
      return baseV1URL + "/\(applicationID)" + "/cancel"
    }

    static func cancelReturn(applicationID: String) -> String {
      return baseV1URL + "/\(applicationID)/return-cancel"
    }

    static func uploadPhoto(applicationID: String) -> String {
      return baseURL + "/upload/\(applicationID)" + "/photo"
    }
    
    static func livenessSession(applicationID: String) -> String {
      return baseURL + "/\(applicationID)" + "/liveness-session"
    }
    
    static func livenessPhoto(applicationID: String) -> String {
      return baseURL + "/upload/\(applicationID)" + "/liveness-photo"
    }

    static func consetForm(applicationID: String) -> String {
      return baseV1URL + "/\(applicationID)" + "/printform/CONSENT_RETURN_FORWARD"
    }
  }

  struct LeasingBasket {
    private static let baseURL = baseRestURLString + "/leasing-basket/v2/basket-online"
    static var create: String {
      return baseURL
    }
    
    static let registerPersonalDataAgreementURL = "https://content.forward.lc/files/subscribe-rf/docs/pd_agreement.pdf"
    
    static func personalDataAgreement(basketID: String) -> String {
      return baseRestURLString + "/leasing-basket/v1/basket-online/\(basketID)" + "/printform/AGREEMENT_SES_FORWARD"
    }

    static func consetForm(basketID: String) -> String {
      return baseRestURLString + "/leasing-basket/v1/basket-online/\(basketID)" + "/printform/CONSENT_PERS_FORWARD"
    }
  }
  
  struct Dictionary {
    private static let baseURL = baseRestURLString + "/dictionary/v1"
    static let searchAddress = baseURL + "/address"
  }
  
  struct Cabinet {
    private static let applicationCabinet = baseRestURLString + "/application/v1/cabinet"
    private static let baseURL = baseRestURLString + "/cabinet/v1"
    static let leasingRules = "https://content.forward.lc/files/subscribe-rf/docs/leasing_rules.pdf"
    static let allApplications = baseURL + "/leasing-application/not-issued"
    static let clentInfo = applicationCabinet + "/client-info"
    
    static func currentApplications(applicationID: String) -> String {
      return baseURL + "/leasing-contract/\(applicationID)/not-issued"
    }

    static let contracts = baseURL + "/leasing-contract"

    static func signedContractPDF(applicationID: String) -> String {
      return contracts + "/\(applicationID)/printform/SIGNED_LEASING_CONTRACT"
    }
    static func leasingActPDF(applicationID: String) -> String {
      return contracts + "/\(applicationID)/printform/SIGNED_ACT"
    }
    static func contractPDF(applicationID: String) -> String {
      return contracts + "/\(applicationID)/printform/LEASING_CONTRACT"
    }
    static func deliveryAgreementPDF(applicationID: String) -> String {
      return contracts + "/\(applicationID)/printform/DELIVERY_ACT_AGREEMENT"
    }
    static func getQuestionnaire(applicationID: String) -> String {
      return contracts + "/\(applicationID)/questionnaire"
    }
    static func contract(applicationID: String) -> String {
      return contracts + "/\(applicationID)"
    }
    static func createContract(applicationID: String) -> String {
      return contracts + "/\(applicationID)/create"
    }
    static func validateContractOTP(applicationID: String) -> String {
      return contracts + "/\(applicationID)/validate-otp"
    }
    static func sendContractOTP(applicationID: String) -> String {
      return contracts + "/\(applicationID)/send-otp"
    }
    static func resendContractOTP(applicationID: String) -> String {
      return contracts + "/\(applicationID)/resend-otp"
    }
    static func getDeliveryTypes(applicationID: String) -> String {
      return contracts + "/\(applicationID)/delivery-types"
    }
    static func saveDeliveryType(applicationID: String) -> String {
      return contracts + "/\(applicationID)/delivery-type"
    }
    static func cancelContract(applicationID: String) -> String {
      return contracts + "/\(applicationID)/cancel"
    }
    static func contractExchangeOffers(applicationID: String) -> String {
      return contracts + "/\(applicationID)/upgrade-offers"
    }
    static func setStorePoint(applicationID: String) -> String {
      return contracts + "/\(applicationID)/set-store"
    }
    static func printDocument(link: String) -> String {
      return baseRestURLString + link
    }
    static func returnContract(applicationID: String) -> String {
    return contracts + "/\(applicationID)/return"
    }
    static func cancelReturn(applicationID: String) -> String {
      return contracts + "/\(applicationID)/return-cancel"
    }
  }
  
  struct Cards {
    private static let baseURL = baseRestURLString + "/templator/v1"
    static let cardTemplates = baseURL + "/card-templates"
    
    static func card(id: String) -> String {
      return cardTemplates + "/\(id)"
    }
  }
  
  struct Auth {
    private static let baseURL = baseRestURLString + "/bouncer/v1"
    static let register = baseURL + "/pin"
    static let login = baseURL + "/token"
    
    static func checkCode(sessionID: String) -> String {
      return register + "/\(sessionID)" + "/smscode"
    }
    
    static func resendSMS(sessionID: String) -> String {
      return register + "/\(sessionID)" + "/resendsms"
    }
    
    static func savePin(sessionID: String) -> String {
      return register + "/\(sessionID)" + "/pin"
    }
  }
  
  struct Bouncer {
    private static let baseURL = baseRestURLString + "/bouncer/v1"
    static let token = baseURL + "/token"
  }
  
  struct LeasingStores {
    private static let baseURL = baseRestURLString + "/leasing-stores/v1" + "/\(Constants.defaultChannel)"
    
    static func storesPoints(categoryCode: String) -> String {
      return baseURL + "/stores/\(categoryCode)"
    }
  }
  
  struct DeliveryAct {
    private static let baseURLv1 = baseRestURLString + "/leasing-delivery/v1"
    private static let baseURLv2 = baseRestURLString + "/leasing-delivery/v2"
    
    private static func deliveryAct(baseURL: String) -> String {
      return baseURL + "/delivery-act"
    }
    
    static func confirm(applicationID: String) -> String {
      return deliveryAct(baseURL: baseURLv1) + "/\(applicationID)/confirm"
    }
    
    static func deliveryInfo(applicationID: String) -> String {
      return deliveryAct(baseURL: baseURLv2) + "/\(applicationID)/delivery-info"
    }
    
    static func deliveryCancel(applicationID: String) -> String {
      return deliveryAct(baseURL: baseURLv2) + "/\(applicationID)/delivery-cancel"
    }
    
    static func partnerOrder(applicationID: String) -> String {
      return deliveryAct(baseURL: baseURLv1) + "/\(applicationID)/partner-order"
    }
    
    static func payment(applicationID: String) -> String {
      return deliveryAct(baseURL: baseURLv1) + "/\(applicationID)/payment"
    }
    
    static func checkPayment(applicationID: String) -> String {
      return deliveryAct(baseURL: baseURLv1) + "/\(applicationID)/payment-check"
    }

    static func signOTP(applicationID: String) -> String {
      return deliveryAct(baseURL: baseURLv1) + "/\(applicationID)/sign-otp"
    }

    static func validateOTP(applicationID: String) -> String {
      return deliveryAct(baseURL: baseURLv1) + "/\(applicationID)/otp"
    }
  }
  
  struct Catalogue {
    private static let baseURL = baseRestURLString + "/leasing-content/v2/catalog/\(Constants.defaultChannel)"
    static let models = baseURL + "/models"
    static let goods = baseURL + "/goods"
    
    static func goodInfo(goodCode: String) -> String {
      return goods + "/\(goodCode)"
    }
    
    static func productInfo(productCode: String) -> String {
      return goods + "/\(productCode)"
    }

    static func goods(modelCode: String) -> String {
      return models + "/\(modelCode)" + "/goods"
    }
  }

  struct Subscription {
    private static let baseURL = baseRestURLString + "/digital-subscriptions/v1/subscription"
    static let subscriptionList = baseURL + "/list?channel=\(Constants.defaultChannel)"
  }
  
  struct Orders {
    private static let baseURL = baseRestURLString + "/orders/v1"
    static let make = baseURL + "/make"
    static let makeUnauthorized = make + "/unauthorized"
  }
  
  struct Payments {
    private static let baseURL = baseRestURLString + "/payments/v2"
    static let payments = baseURL + "/payments"
  }
  
  struct Documents {
    static let personalDataPolicy = "https://content.forward.lc/files/subscribe-rf/docs/site_pd_agreement.pdf"
    static let leasingRules = "https://content.forward.lc/files/subscribe-rf/docs/leasing_rules.pdf"
  }

  struct Configuration {
    private static let baseURL = baseRestURLString + "/configuration/v1"
    static let configuration = baseURL + "/configuration/\(Constants.deviceType)"
  }
  
  struct LeasingContent {
    // TODO: Switch to actual URL
    private static let baseURL = "https://kode.sheverev.com/leasing-content/v3/channel/CHANNEL"
    
    static func mainpage() -> String {
      return baseURL + "/screen/mainpage"
    }
  }
}
