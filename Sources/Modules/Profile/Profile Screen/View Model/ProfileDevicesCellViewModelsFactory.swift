//
//  ProfileDevicesCellViewModelsFactory.swift
//  ForwardLeasing
//

import Foundation
import CoreGraphics

struct ProfileDeviveCellConfiguration {
  let leasingEntity: LeasingEntity
  let additionalLeasingEntity: LeasingEntity?
}

class ProfileDevicesCellViewModelsFactory {
  // MARK: - Properties
  private let configurations: [ProfileDeviveCellConfiguration]
  private let cellDelegate: ProfileCellViewModelsDelegate
  private let paymentsFormatter = PaymentsFormatter()
  
  // MARK: - Init
  init(configurations: [ProfileDeviveCellConfiguration],
       cellDelegate: ProfileCellViewModelsDelegate) {
    self.configurations = configurations
    self.cellDelegate = cellDelegate
  }

  // MARK: - Public methods
  func makeCellViewModels() -> [CommonTableCellViewModel] {
    let viewModels = configurations.map {
      return makeCellViewModel(configuration: $0)
    }
    return viewModels
  }

  // MARK: - Private methods
  private func makeCellViewModel(configuration: ProfileDeviveCellConfiguration) -> CommonTableCellViewModel {
    switch configuration.leasingEntity.entityType {
    case .application:
      return makeApplicationCellViewModel(configuration: configuration)
    case .contract:
      return makeContractCellViewModel(configuration: configuration)
    }
  }

  private func makeApplicationCellViewModel(configuration: ProfileDeviveCellConfiguration) -> CommonTableCellViewModel {
    let leasingEntity = configuration.leasingEntity
    
    var descriptions: [ProductDescriptionConfiguration] = []
    var buttonsActions: [ProductButtonAction] = []

    switch leasingEntity.status {
    case .draft, .confirmed, .dataSaved, .pending:
      buttonsActions.append(contentsOf: [.continue, .cancelApplication])
    case .inReview:
      descriptions.append(ProductDescriptionConfiguration(title: leasingEntity.statusTitle ?? "",
                                                          color: .accent))
      buttonsActions.append(contentsOf: [.checkStatus, .cancelApplication])
    case .approved:
      descriptions.append(ProductDescriptionConfiguration(title: leasingEntity.statusTitle ?? "",
                                                          color: .access))
      buttonsActions.append(contentsOf: [.signСontract, .cancelApplication])
    default:
      // TODO: remove after testing
      return TemporaryCellViewModel(title: "Не верный статус", onDidSelect: nil)
    }

    return makeProductCellModel(leasingEntity: leasingEntity,
                                descriptions: descriptions,
                                buttonsActions: buttonsActions,
                                deliveryViewModel: nil,
                                statusDescriptionViewModel: nil)
  }

  private func makeContractCellViewModel(configuration: ProfileDeviveCellConfiguration) -> CommonTableCellViewModel {
    let leasingEntity = configuration.leasingEntity
    let additionalLeasingEntity = configuration.additionalLeasingEntity
    
    var descriptions: [ProductDescriptionConfiguration] = []
    var buttonsActions: [ProductButtonAction] = []
    var deliveryViewModel: ProductDeliveryViewModel?
    var statusDescriptionViewModel: ProductStatusDescriptionViewModel?

    switch leasingEntity.status {
    case .signed where leasingEntity.deliveryType != .pickup && (leasingEntity.contractActionInfo?.deliveryInfo?.deliveryStatus == nil ||
          leasingEntity.contractActionInfo?.deliveryInfo?.deliveryStatus == DeliveryStatus.none ||
          leasingEntity.contractActionInfo?.deliveryInfo?.deliveryStatus == .ok):
      descriptions.append(ProductDescriptionConfiguration(title: leasingEntity.statusTitle ?? "",
                                                          color: .access))
      statusDescriptionViewModel = makeProductStatusDescriptionViewModel(leasingEntity: leasingEntity)
      buttonsActions.append(contentsOf: [.selectDeliveryType, .cancelContract])
    case .signed where leasingEntity.deliveryType == .pickup && leasingEntity.contractActionInfo?.storePoint != nil, .actSigned:
      statusDescriptionViewModel = makeProductStatusDescriptionViewModel(leasingEntity: leasingEntity)
      buttonsActions.append(contentsOf: [.pickupWithStorePoint, .cancelContract])
    case .signed where leasingEntity.deliveryType == .pickup && leasingEntity.contractActionInfo?.storePoint == nil:
      statusDescriptionViewModel = makeProductStatusDescriptionViewModel(leasingEntity: leasingEntity)
      buttonsActions.append(contentsOf: [.pickupWithoutStorePoint, .cancelContract])
    case .deliveryStarted where leasingEntity.contractActionInfo?.deliveryInfo?.status == .created:
      descriptions.append(ProductDescriptionConfiguration(title: leasingEntity.statusTitle ?? "",
                                                          color: .shade70))
      statusDescriptionViewModel = makeProductStatusDescriptionViewModel(leasingEntity: leasingEntity)
      buttonsActions.append(contentsOf: [.signDelivery, .cancelDelivery])
    case .contractCreated where leasingEntity.contractActionInfo?.deliveryInfo?.status == .cancelPayment,
         .deliveryCreated where leasingEntity.contractActionInfo?.deliveryInfo?.status == .cancelPayment,
         .deliveryStarted where leasingEntity.contractActionInfo?.deliveryInfo?.status == .cancelPayment:
      statusDescriptionViewModel = makeProductStatusDescriptionViewModel(leasingEntity: leasingEntity)
      descriptions.append(ProductDescriptionConfiguration(title: R.string.productCard.deliveryCanceled(),
                                                          color: .shade70))
    case .contractInit, .contractCreated, .signSmsSend:
      descriptions.append(ProductDescriptionConfiguration(title: leasingEntity.statusTitle ?? "",
                                                          color: .shade70))
      buttonsActions.append(contentsOf: [.signСontract, .cancelContract])
    case .deliveryStarted, .deliveryCreated, .deliveryShipped:
      deliveryViewModel = makeDeliveryViewModel(leasingEntity: leasingEntity)
      descriptions.append(ProductDescriptionConfiguration(title: leasingEntity.statusTitle ?? "",
                                                          color: .access))
    case .inBackoffice:
      let title = paymentsFormatter.paymentDateString(with: leasingEntity.contractInfo?.nextPaymentDate)
      descriptions.append(ProductDescriptionConfiguration(title: title,
                                                          color: .shade70))
      statusDescriptionViewModel = makeProductStatusDescriptionViewModel(leasingEntity: leasingEntity)
      buttonsActions.append(contentsOf: [.pay])
    case .upgradeCreated:
      var title = R.string.profile.exchangeApplicationCreatedTitle()
      if let date = additionalLeasingEntity?.expirationDate {
        title += "\n" + R.string.profile.applicationExpirationDateTitle(DateFormatter.dayMonthYearDocument.string(from: date))
      }
      descriptions.append(ProductDescriptionConfiguration(title: title,
                                                          color: .access))
      statusDescriptionViewModel = makeProductStatusDescriptionViewModel(leasingEntity: leasingEntity)
      buttonsActions.append(contentsOf: [.upgrade, .cancelUpgradeApplication])
    case .returnCreated:
      var title = R.string.profile.returnApplicationCreatedTitle()
      if let date = leasingEntity.contractActionInfo?.actExpirationDate {
        title += "\n" + R.string.profile.applicationExpirationDateTitle(DateFormatter.dayMonthYearDocument.string(from: date))
      }
      descriptions.append(ProductDescriptionConfiguration(title: title,
                                                          color: .access))
      statusDescriptionViewModel = makeProductStatusDescriptionViewModel(leasingEntity: leasingEntity)
      buttonsActions.append(contentsOf: [.return, .cancelReturnApplication])
    default:
      // TODO: remove after testing
      return TemporaryCellViewModel(title: "Не верный статус", onDidSelect: nil)
    }
    return makeProductCellModel(leasingEntity: leasingEntity,
                                descriptions: descriptions,
                                buttonsActions: buttonsActions,
                                deliveryViewModel: deliveryViewModel,
                                statusDescriptionViewModel: statusDescriptionViewModel)
  }

  private func makeProductCellModel(leasingEntity: LeasingEntity,
                                    descriptions: [ProductDescriptionConfiguration],
                                    buttonsActions: [ProductButtonAction],
                                    deliveryViewModel: ProductDeliveryViewModel?,
                                    statusDescriptionViewModel: ProductStatusDescriptionViewModel?) -> CommonTableCellViewModel {
    let productInfoViewModel = makeProductInfoViewModel(leasingEntity: leasingEntity,
                                                        descriptions: descriptions)
    let productButtonsViewModel = ProductButtonsViewModel(buttonsActions: buttonsActions)

    let viewModel = ProductViewModel(leasingEntity: leasingEntity,
                                     infoViewModel: productInfoViewModel,
                                     deliveryViewModel: deliveryViewModel,
                                     statusDescriptionViewModel: statusDescriptionViewModel,
                                     buttonsViewModel: productButtonsViewModel)
    viewModel.delegate = cellDelegate
    return viewModel
  }
  
  private func makeProductInfoViewModel(leasingEntity: LeasingEntity,
                                        descriptions: [ProductDescriptionConfiguration]) -> ProductInfoViewModel {
    let productName = leasingEntity.productInfo.goodName ?? ""
    let monthPayTitle = paymentsFormatter.monthPaymentString(for: leasingEntity.productInfo.monthPay)
    let imageViewType = makeImageViewType(leasingEntity: leasingEntity)
    
    let productDescriptionViewModel = ProductDescriptionViewModel(descriptions: descriptions,
                                                                  nameTitle: productName,
                                                                  paymentTitle: monthPayTitle)
    return ProductInfoViewModel(descriptionViewModel: productDescriptionViewModel,
                                imageViewType: imageViewType)
  }
  
  private func makeImageViewType(leasingEntity: LeasingEntity) -> ImageViewType {
    let imageURL: URL? = try? leasingEntity.productImage?.asURL()

    let productImageViewModel = ProductImageViewModel(imageURL: imageURL)
    let circleProgressInfo = CircleProgressInfo.make(from: leasingEntity)
    // TODO - Insert real product type
    let insets = ProductProgressImageViewInsets(type: .smartphone)
    let productProgressImageViewModel = ProductProgressImageViewModel(circleProgressInfo: circleProgressInfo,
                                                                      productImageViewModel: productImageViewModel,
                                                                      insets: insets)
    let progressLeasingStatuses: [LeasingEntityStatus] = [.inBackoffice, .upgradeCreated, .returnCreated]
    return progressLeasingStatuses.contains(leasingEntity.status)
      ? .progress(productProgressImageViewModel)
      : .simple(productImageViewModel)
  }
  
  private func makeDeliveryViewModel(leasingEntity: LeasingEntity) -> ProductDeliveryViewModel {
    let currentStep: Int
    
    if leasingEntity.contractActionInfo?.deliveryHistory.contains(where: { $0.deliveryStatus == .delivered }) ?? false {
      currentStep = 4
    } else if leasingEntity.contractActionInfo?.deliveryHistory.contains(where: { $0.deliveryStatus == .delivering }) ?? false {
      currentStep = 3
    } else if leasingEntity.contractActionInfo?.deliveryHistory.contains(where: { $0.deliveryStatus == .shipped }) ?? false {
      currentStep = 2
    } else if leasingEntity.contractActionInfo?.deliveryHistory.contains(where: { $0.deliveryStatus == .new }) ?? false {
      currentStep = 1
    } else {
      currentStep = 0
    }
      
    return ProductDeliveryViewModel(currentStep: currentStep,
                                    stepsCount: 4,
                                    description: leasingEntity.statusDescription ?? "",
                                    descriptionColor: .shade70)
  }
  
  private func makeProductStatusDescriptionViewModel(leasingEntity: LeasingEntity) -> ProductStatusDescriptionViewModel {
    let title: String
    switch leasingEntity.status {
    case .inBackoffice:
      title = paymentsFormatter.paidTotalString(payedSum: leasingEntity.contractInfo?.payedSum,
                                                remainsSum: leasingEntity.contractInfo?.remainsSum)
    case .upgradeCreated, .returnCreated:
      title = ""
    default:
      title = leasingEntity.statusDescription ?? ""
    }
    let descriptionConfiguration = ProductDescriptionConfiguration(title: title,
                                                                   color: .shade70)
    return ProductStatusDescriptionViewModel(productDescriptionConfiguration: descriptionConfiguration)
  }
}
