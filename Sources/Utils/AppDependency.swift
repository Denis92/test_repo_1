//
//  AppDependency.swift
//  ForwardLeasing
//

import Foundation

protocol HasUserDataStore {
  var userDataStore: UserDataStoring { get }
}

protocol HasPersonalDataRegisterService {
  var personalDataRegistrationService: PersonalDataRegistrationProtocol { get }
}

protocol HasBasketService {
  var basketService: BasketNetworkProtocol { get }
}

protocol HasTokenStorage {
  var tokenStorage: TokenStoring { get set }
}

protocol HasApplicationService {
  var applicationService: ApplicationNetworkProtocol { get }
}

protocol HasContractService {
  var contractService: ContractNetworkProtocol { get }
}

protocol HasCheckPhotosService {
  var checkPhotosService: CheckPhotosProtocol { get }
}

protocol HasDictionaryService {
  var dictionaryService: DictionaryNetworkProtocol { get }
}

protocol HasAuthService {
  var authService: AuthNetworkProtocol { get }
}

protocol HasProfileService {
  var profileService: ProfileNetworkProtocol { get }
}

protocol HasDeliveryService {
  var deliveryService: DeliveryNetworkProtocol { get }
}

protocol HasMapService {
  var mapService: MapService { get }
}

protocol HasCardsService {
  var cardsService: CardsNetworkProtocol { get }
}

protocol HasPaymentsService {
  var paymentsService: PaymentsNetworkProtocol { get }
}

protocol HasSubscriptionsService {
  var subscriptionsService: SubscriptionsNetworkProtocol { get }
}

protocol HasCatalogueService {
  var catalogueService: CatalogueNetworkProtocol { get }
}

protocol HasOrdersService {
  var ordersService: OrdersNetworkProtocol { get }
}

protocol HasDeeplinkService {
  var deeplinkService: DeeplinkService { get }
}

protocol HasConfigurationService {
  var configurationService: ConfigurationNetworkProtocol { get }
}

protocol HasDiagnosticService {
  var diagnosticService: DiagnosticServiceProtocol { get }
}

protocol HasLeasingContentService {
  var leasingContentService: LeasingContentNetworkProtocol { get }
}

class AppDependency: HasUserDataStore, HasTokenStorage, HasMapService, HasDeeplinkService {
  let userDataStore: UserDataStoring
  let mapService: MapService
  let deeplinkService: DeeplinkService
  let diagnosticService: DiagnosticServiceProtocol
  
  weak var logoutHandler: LogoutHandler?
  weak var authHandler: AuthHandler?
  var tokenStorage: TokenStoring

  var networkServiceDelegate: NetworkServiceDelegate? {
    get { return networkService.delegate }
    set { networkService.delegate = newValue }
  }
  
  var tokenRefreshDelegate: TokenRefreshDelegate? {
    get { return networkService.tokenRefreshDelegate }
    set { networkService.tokenRefreshDelegate = newValue }
  }

  private let networkService: NetworkService

  init(userDataStore: UserDataStoring,
       tokenStorage: TokenStoring,
       networkService: NetworkService,
       mapService: MapService,
       deeplinkService: DeeplinkService,
       diagnosticService: DiagnosticServiceProtocol) {
    self.userDataStore = userDataStore
    self.networkService = networkService
    self.tokenStorage = tokenStorage
    self.mapService = mapService
    self.deeplinkService = deeplinkService
    self.diagnosticService = diagnosticService
  }

  static func makeDefault() -> AppDependency {
    let userDataStore = UserDataStore()
    let networkService = NetworkService(tokenStorage: userDataStore)
    let mapService = MapService()
    let deeplinkService = DeeplinkService()
    let diagnosticService = DiagnosticService(userDataStore: userDataStore)
    return AppDependency(userDataStore: userDataStore,
                         tokenStorage: userDataStore,
                         networkService: networkService,
                         mapService: mapService,
                         deeplinkService: deeplinkService,
                         diagnosticService: diagnosticService)
  }
}

// MARK: - HasPersonalDataRegisterService
extension AppDependency: HasPersonalDataRegisterService {
  var personalDataRegistrationService: PersonalDataRegistrationProtocol { networkService }
}

// MARK: - HasBasketService
extension AppDependency: HasBasketService {
  var basketService: BasketNetworkProtocol { networkService }
}

// MARK: - HasApplicationService
extension AppDependency: HasApplicationService {
  var applicationService: ApplicationNetworkProtocol { networkService }
}

// MARK: - HasCheckPhotosService
extension AppDependency: HasCheckPhotosService {
  var checkPhotosService: CheckPhotosProtocol { networkService }
}

// MARK: - HasDictionaryService
extension AppDependency: HasDictionaryService {
  var dictionaryService: DictionaryNetworkProtocol { networkService }
}

// MARK: - HasAuthService
extension AppDependency: HasAuthService {
  var authService: AuthNetworkProtocol { networkService }
}

// MARK: - HasProfileService
extension AppDependency: HasProfileService {
  var profileService: ProfileNetworkProtocol { networkService }
}
  
// MARK: - HasLeasingStoresService
extension AppDependency: HasDeliveryService {
  var deliveryService: DeliveryNetworkProtocol { networkService }
}

// MARK: - HasContractService
extension AppDependency: HasContractService {
  var contractService: ContractNetworkProtocol { networkService }
}

// MARK: - HasCardsService
extension AppDependency: HasCardsService {
  var cardsService: CardsNetworkProtocol { networkService }
}

// MARK: - HasPaymentsService
extension AppDependency: HasPaymentsService {
  var paymentsService: PaymentsNetworkProtocol { networkService }
}

// MARK: - HasSubscriptionsService
extension AppDependency: HasSubscriptionsService {
  var subscriptionsService: SubscriptionsNetworkProtocol { networkService}
}

// MARK: - HasCatalogueService
extension AppDependency: HasCatalogueService {
  var catalogueService: CatalogueNetworkProtocol { networkService }
}

// MARK: - HasOrdersService
extension AppDependency: HasOrdersService {
  var ordersService: OrdersNetworkProtocol { networkService }
}

// MARK: - HasConfigurationService
extension AppDependency: HasConfigurationService {
  var configurationService: ConfigurationNetworkProtocol { networkService }
}

// MARK: - HasLeasingContentService
extension AppDependency: HasLeasingContentService {
  var leasingContentService: LeasingContentNetworkProtocol { networkService }
}
