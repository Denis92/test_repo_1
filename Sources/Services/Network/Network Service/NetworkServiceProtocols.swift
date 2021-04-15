//
//  NetworkServiceProtocols.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

// MARK: - Cache

protocol NetworkRequestsCaching {
  func invalidateCaches(for cacheInfos: [CacheInfo], groups: [String]) throws
}

// MARK: - Create Leasing Application
protocol PersonalDataRegistrationProtocol {
  func createLeasingApplication(basketID: String, type: LeasingApplicationType,
                                email: String, phone: String, previousApplicationID: String?) -> Promise<LeasingEntity>
  func resendSmsCode(applicationID: String) -> Promise<EmptyResponse>
  func refreshToken(applicationID: String) -> Promise<EmptyResponse>
  func checkRefreshTokenOTPCode(code: String, applicationID: String) -> Promise<CheckCodeResult>
  func checkCode(code: String, applicationID: String) -> Promise<CheckCodeResult>
  func searchAddress(text: String) -> Promise<AddressResponse>
}

// MARK: - Leasing Application Basket
protocol BasketNetworkProtocol {
  func createBasket(productCode: String, deliveryType: DeliveryType, userID: String) -> Promise<CreateBasketResponse>
}

// MARK: - ApplicationNetworkProtocol
protocol ApplicationNetworkProtocol {
  func getApplicationData(applicationID: String) -> Promise<LeasingEntity>
  func checkOtherApplications(applicationID: String) -> Promise<[LeasingEntity]>
  func checkAllApplications() -> Promise<[LeasingEntity]>
  func checkApplicationStatus(applicationID: String) -> Promise<LeasingEntity>
  func sendApplicationForScoring(applicationID: String) -> Promise<LeasingEntity>
  func cancelApplication(applicationID: String) -> Promise<EmptyResponse>
  func cancelReturnApplication(applicationID: String) -> Promise<EmptyResponse>
  func getClientInfo() -> Promise<MaskedClientInfo>
  func uploadPassportScan(applicationID: String, imageData: Data) -> Promise<PassportScanResponse>
  func startLivenessSession(applicationID: String) -> Promise<LivenessCredentials>
  func checkLivenessPhoto(applicationID: String) -> Promise<EmptyResponse>
  func saveClientData(data: ClientPersonalData, applicationID: String) -> Promise<ApplicationInfoResponse>
  func saveClientData(monthlySalary: Int, occupation: String, applicationID: String) -> Promise<EmptyResponse> 
  func cancelContract(applicationID: String) -> Promise<EmptyResponse>
}

// MARK: - ContractNetworkProtocol

protocol ContractNetworkProtocol: NetworkRequestsCaching {
  func getContract(applicationID: String, useCache: Bool) -> Promise<LeasingEntityResponse>
  func createContract(applicationID: String) -> Promise<EmptyResponse>
  func sendContractCode(applicationID: String) -> Promise<EmptyResponse>
  func checkContractCode(code: String, applicationID: String) -> Promise<CheckCodeResult>
  func resendContractSmsCode(applicationID: String) -> Promise<EmptyResponse>
  func cancelContract(applicationID: String) -> Promise<EmptyResponse>
  func getExchangeOffers(applicationID: String) -> Promise<ExchangeOffersResponse>
  func getQuestionnaire(applicationID: String) -> Promise<QuestionnaireResponse>
  func returnContract(applicationID: String) -> Promise<LeasingEntityResponse>
  func cancelReturn(applicationID: String) -> Promise<EmptyResponse>
}

// MARK: - DictionaryNetworkProtocol
protocol DictionaryNetworkProtocol {
  func searchAddress(text: String) -> Promise<AddressResponse>
}

// MARK: - Photos
protocol CheckPhotosProtocol {
  func checkPhotos(applicationID: String) -> Promise<CheckPhotosResult>
}

// MARK: - AuthNetworkProtocol
protocol AuthNetworkProtocol {
  func signIn(phone: String, pin: String) -> Promise<CheckCodeResult>
  func register(email: String, phone: String) -> Promise<SessionResponse>
  func recoveryPin(phone: String) -> Promise<SessionResponse>
  func checkCode(code: String, sessionID: String) -> Promise<CheckCodeResult>
  func resendSmsCode(sessionID: String) -> Promise<EmptyResponse>
  func savePin(pinCode: String, sessionID: String) -> Promise<TokenResponse>
}

// MARK: - CreateApplicationNetworkProtocol
protocol CreateApplicationNetworkProtocol {
  func createBasket() -> Promise<EmptyResponse>
  func createNewApplication(basketID: String, email: String, phone: String, previousApplicationID: String?) -> Promise<EmptyResponse>
}

// MARK: - ProfileNetworkProtocol
protocol ProfileNetworkProtocol: NetworkRequestsCaching {
  func leasingContracts() -> Promise<[LeasingEntity]>
}

// MARK: - DeliveryNetworkProtocol
protocol DeliveryNetworkProtocol {
  func getStores(categoryCode: String, goodCode: String?) -> Promise<StoresResponse>
  func getDeliveryTypes(applicationID: String) -> Promise<[ProductDeliveryOption]>
  func getDeliveryInfo(applicationID: String, addressResult: AddressResult) -> Promise<ProductDeliveryInfo>
  func cancelDelivery(applicationID: String) -> Promise<EmptyResponse>
  func saveDeliveryType(applicationID: String, deliveryType: DeliveryType) -> Promise<LeasingEntity>
  func saveApplicationDelivery(applicationID: String) -> Promise<OrderStatus>
  func pay(applicationID: String, isCancelPrevious: Bool) -> Promise<PaymentResponse>
  func checkPayment(applicationID: String) -> Promise<CheckPaymentResponse>
  func confirmPayment(applicationID: String) -> Promise<EmptyResponse>
  func setStore(applicationID: String, storePoint: StorePointInfo) -> Promise<LeasingEntity>
  func signOTP(applicationID: String) -> Promise<EmptyResponse>
  func validateOTP(code: String, applicationID: String) -> Promise<CheckCodeResult>
}

// MARK: - CatalogueNetworkProtocol
protocol CatalogueNetworkProtocol {
  func getProductInfo(productCode: String) -> Promise<ProductInfoResponse>
  func getGoods(with modelCode: String) -> Promise<ModelGoodsResponse>
}

// MARK: - Cards
protocol CardsNetworkProtocol {
  func getCards() -> Promise<[Card]>
  func deleteCard(with id: String) -> Promise<EmptyResponse>
}

// MARK: - Payments
protocol PaymentsNetworkProtocol {
  func pay(paymentInfo: PaymentInfo) -> Promise<PaymentRegistrationResponse>
}

// MARK: - Subscriptions
protocol SubscriptionsNetworkProtocol {
  func subscriptionList() -> Promise<[BoughtSubscription]>
}

// MARK: - Orders
protocol OrdersNetworkProtocol {
  func makeOrder(subscriptionID: String, card: PaymentCard, saveCard: Bool, email: String) -> Promise<PaymentResponse>
  func makeOrderUnathorized(subscriptionID: String, card: PaymentCard, email: String, phoneNumber: String) -> Promise<PaymentResponse>
}

// MARK: - Configuration
protocol ConfigurationNetworkProtocol {
  func getConfiguration() -> Promise<ConfigurationReponse>
}

// MARK: - LeasingContentNetworkProtocol
protocol LeasingContentNetworkProtocol {
  func getMainpageData() -> Promise<LeasingContentResponse>
}
