//
//  ProductDetailsViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

protocol ProductDetailsViewModelDelegate: class {
  func productDetailsViewModel(_ viewModel: ProductDetailsViewModel, didRequestToOpenURL url: URL?,
                               title: String?)
  func productDetailsViewModel(_ viewModel: ProductDetailsViewModel, didRequestToBuyProduct product: LeasingProductInfo,
                               basketID: String)
  func productDetailsViewModel(_ viewModel: ProductDetailsViewModel, didRequestToExchangeProduct product: ProductDetails)
}

struct ProductDetailsViewModelInput {
  let bottomButtonType: ProductDetailsBottomButtonType
  let modelCode: String?
}

enum ProductDetailsBottomButtonType {
  case order, exchange
}

class ProductDetailsViewModel: BindableViewModel {
  typealias Dependencies = HasBasketService & HasUserDataStore & HasCatalogueService

  weak var delegate: ProductDetailsViewModelDelegate?
  
  // TODO: - Needs refactor later
  private (set) var productTitle: String = ""
  private (set) var infoWebViewModels: [ProductInfoWebViewModel] = []
  private (set) lazy var buttonConfiguration: StandardButtonConfiguration = makeStandardButtonConfiguration()
  private (set) var itemsViewModels: [ProductDetailsItemViewModel] = []

  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidLoadData: (() -> Void)?
  var onDidStartBasketCreation: (() -> Void)?
  var onDidFinishBasketCreation: (() -> Void)?

  private var productDetails: ProductDetails?
  private var monthlyPaymentViewModel: ProductMonthlyPaymentViewModel?
  private let modelCode: String?
  private let dependencies: Dependencies
  private let bottomButtonType: ProductDetailsBottomButtonType
  private let leasingEntity: LeasingEntity?

  init(dependencies: Dependencies, input: ProductDetailsViewModelInput) {
    self.dependencies = dependencies
    self.bottomButtonType = input.bottomButtonType
    self.modelCode = input.modelCode
    self.leasingEntity = nil
  }

  func loadData() {
    if let modelCode = modelCode {
      loadProductDetails(with: modelCode)
    } else {
      let productDetails = ProductDetails()
      makeStubViewModels(with: productDetails)
      onDidLoadData?()
    }
  }

  private func loadProductDetails(with modelCode: String) {
    onDidStartRequest?()
    firstly {
      dependencies.catalogueService.getGoods(with: modelCode)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { response in
      self.makeViewModels(with: response.goods)
      self.onDidLoadData?()
    }.catch { error in
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }

  func didTapBottomButton() {
    switch bottomButtonType {
    case .order:
      buy()
    case .exchange:
      exchange()
    }
  }

  private func makeViewModels(with productDetails: [ProductDetails]) {
    guard let productDetail = productDetails.first else {
      return
    }
    self.productDetails = productDetail
    self.productTitle = productDetail.name
    itemsViewModels.removeAll()

    let imageCarouselViewModel = ProductImageCarouselViewModel(images: productDetail.images, type: productDetail.type)
    itemsViewModels.append(imageCarouselViewModel)

    let colors: [ProductColor] = productDetails.map { $0.color }
    if colors.isNotEmpty {
      let colorPickerViewModel = ProductColorPickerViewModel(colors: colors)
      colorPickerViewModel.delegate = self
      itemsViewModels.append(colorPickerViewModel)
    }

    let parameters: [ProductParameter] = productDetail.parameters.filter { $0.type == .volume }
    if parameters.isNotEmpty {
      let memoryPickerViewModel = ProductParameterPickerViewModel(title: "Объем памяти",
                                                                  parameters: parameters)
      memoryPickerViewModel.delegate = self
      itemsViewModels.append(memoryPickerViewModel)
    }

    let paymentsCountViewModel = ProductPaymentsCountViewModel(leasingOptions: [productDetail.leasingInfo])
    paymentsCountViewModel.delegate = self
    itemsViewModels.append(paymentsCountViewModel)

    let additionalServices: [ProductAdditionalService] = productDetail.additionalServices
    if additionalServices.isNotEmpty {
      let programPickerViewModel = ProductProgramPickerViewModel(services: additionalServices)
      programPickerViewModel.delegate = self
      itemsViewModels.append(programPickerViewModel)
    }

    let deliveryOptions: [ProductDeliveryOption] = [productDetail.leasingInfo.deliveryInfo].compactMap { $0 }
    if deliveryOptions.isNotEmpty {
      let deliveryTypeViewModel = ProductDeliveryTypeViewModel(deliveryOptions: deliveryOptions)
      deliveryTypeViewModel.delegate = self
      itemsViewModels.append(deliveryTypeViewModel)
    }

    if let leasingSum = productDetail.leasingInfo.leasingSum, let residualSum = productDetail.leasingInfo.residualValue {
      let monthlyPaymentViewModel = ProductMonthlyPaymentViewModel(leasingSum: leasingSum,
                                                                   residualSum: residualSum,
                                                                   paymentsCount: productDetail.leasingInfo.paymentsCount)
      self.monthlyPaymentViewModel = monthlyPaymentViewModel
      itemsViewModels.append(monthlyPaymentViewModel)
    }

    // swiftlint:disable:next line_length
    let advantagesViewModel = ProductAdvantagesViewModel(contentItems: [ProductContentItem(code: "", imageLink: Bundle.main.url(forResource: "12", withExtension: "png")?.absoluteString, title: "Бесплатно после 12 платежей\nНа любую модель Apple из каталога", content: "Обмен на новый"), ProductContentItem(code: "", imageLink: Bundle.main.url(forResource: "6", withExtension: "png")?.absoluteString, title: "6900 ₽ после 6 платежей", content: "Ранний обмен на новый"), ProductContentItem(code: "", imageLink: Bundle.main.url(forResource: "default", withExtension: "png")?.absoluteString, title: "Доставка по всей России", content: "Доставка до порога")])
    itemsViewModels.append(advantagesViewModel)

    let features: [ProductFeature] = productDetail.features
    if features.isNotEmpty {
      let featuresViewModel = ProductFeaturesViewModel(features: features)
      itemsViewModels.append(featuresViewModel)
      let fullFeaturesViewModel = ProductFullFeaturesViewModel(description: productDetail.description,
                                                               features: features)
      itemsViewModels.append(fullFeaturesViewModel)
    }

    // swiftlint:disable:next line_length
    self.infoWebViewModels = [ProductInfoWebViewModel(title: "Как работает сервис?", htmlInfoType: .digits), ProductInfoWebViewModel(title: "Смартфон как услуга", htmlInfoType: .video), ProductInfoWebViewModel(title: "Доставка, подключение и бесплатный ремонт", htmlInfoType: .digits)]
  }

  private func makeStubViewModels(with productDetails: ProductDetails) {
    self.productDetails = productDetails
    self.productTitle = productDetails.name
    
    itemsViewModels.removeAll()
    let imageCarouselViewModel = ProductImageCarouselViewModel(images: productDetails.images, type: productDetails.type)
    itemsViewModels.append(imageCarouselViewModel)

    // swiftlint:disable:next line_length
    let colorPickerViewModel = ProductColorPickerViewModel(colors: [ProductColor(colorCode: "#000000", colorName: "Чёрный"), ProductColor(colorCode: "#DC0C2E", colorName: "Красный"), ProductColor(colorCode: "#FAFAFA", colorName: "Белый")])
    colorPickerViewModel.delegate = self
    itemsViewModels.append(colorPickerViewModel)

    // swiftlint:disable:next line_length
    let memoryPickerViewModel = ProductParameterPickerViewModel(title: "Объем памяти", parameters: [ProductParameter(name: "Объём памяти", value: "64", type: .volume), ProductParameter(name: "Объём памяти", value: "128", type: .volume), ProductParameter(name: "Объём памяти", value: "256", type: .volume)])
    memoryPickerViewModel.delegate = self
    itemsViewModels.append(memoryPickerViewModel)

    // swiftlint:disable:next line_length
//    let paymentsCountViewModel = ProductPaymentsCountViewModel(leasingOptions: [LeasingProductInfo(paymentsCount: 12), LeasingProductInfo(paymentsCount: 24)])
//    paymentsCountViewModel.delegate = self
//    itemsViewModels.append(paymentsCountViewModel)

    let programPickerViewModel = ProductProgramPickerViewModel(services: [ProductAdditionalService(name: "Бесплатная замена экрана 1 раз в год", price: 9999)])
    programPickerViewModel.delegate = self
    itemsViewModels.append(programPickerViewModel)
    
    // swiftlint:disable:next line_length
    let deliveryTypeViewModel = ProductDeliveryTypeViewModel(deliveryOptions: [ProductDeliveryOption(type: .delivery, name: "Курьером", isDefault: true), ProductDeliveryOption(type: .pickup, name: "Самовывоз", isDefault: false)])
    deliveryTypeViewModel.delegate = self
    itemsViewModels.append(deliveryTypeViewModel)


    let monthlyPaymentViewModel = ProductMonthlyPaymentViewModel(leasingSum: 50980, residualSum: 15796, paymentsCount: 12)
    self.monthlyPaymentViewModel = monthlyPaymentViewModel
    itemsViewModels.append(monthlyPaymentViewModel)

    // swiftlint:disable:next line_length
    let advantagesViewModel = ProductAdvantagesViewModel(contentItems: [ProductContentItem(code: "", imageLink: Bundle.main.url(forResource: "12", withExtension: "png")?.absoluteString, title: "Бесплатно после 12 платежей\nНа любую модель Apple из каталога", content: "Обмен на новый"), ProductContentItem(code: "", imageLink: Bundle.main.url(forResource: "6", withExtension: "png")?.absoluteString, title: "6900 ₽ после 6 платежей", content: "Ранний обмен на новый"), ProductContentItem(code: "", imageLink: Bundle.main.url(forResource: "default", withExtension: "png")?.absoluteString, title: "Доставка по всей России", content: "Доставка до порога")])
    itemsViewModels.append(advantagesViewModel)

    let featuresViewModel = ProductFeaturesViewModel(features: productDetails.features)
    itemsViewModels.append(featuresViewModel)

    let fullFeaturesViewModel = ProductFullFeaturesViewModel(description: productDetails.description,
                                                              features: productDetails.features)
    itemsViewModels.append(fullFeaturesViewModel)

    // swiftlint:disable:next line_length
    self.infoWebViewModels = [ProductInfoWebViewModel(title: "Как работает сервис?", htmlInfoType: .digits), ProductInfoWebViewModel(title: "Смартфон как услуга", htmlInfoType: .video), ProductInfoWebViewModel(title: "Доставка, подключение и бесплатный ремонт", htmlInfoType: .digits)]
  }

  private func buy() {
    guard let productDetails = productDetails else {
      return
    }
    // TODO: get selected delivery type
    onDidStartBasketCreation?()
    firstly {
      // TODO: send actual product code
      dependencies.basketService.createBasket(productCode: modelCode ?? "MWHF2RU~A",
                                              deliveryType: .delivery,
                                              userID: dependencies.userDataStore.userID)
    }.ensure {
      self.onDidFinishBasketCreation?()
    }.done { response in
      let product = LeasingProductInfo(productName: productDetails.name, monthPay: 3235,
                                       productImage: productDetails.images.first?.imageLink)
      self.delegate?.productDetailsViewModel(self, didRequestToBuyProduct: product,
                                             basketID: response.basketID)
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }
  
  private func exchange() {
    guard let productDetails = productDetails else {
      return
    }
    delegate?.productDetailsViewModel(self, didRequestToExchangeProduct: productDetails)
  }

  private func makeStandardButtonConfiguration() -> StandardButtonConfiguration {
    let title: String?
    switch bottomButtonType {
    case .order:
      title = R.string.productDetails.makeOrderButtonTitle(monthlyPaymentViewModel?.monthlySumText ?? "")
    case .exchange:
      title = R.string.productDetails.exchangeButtonTitle()
    }
    return StandardButtonConfiguration(style: .primary, title: title)
  }
}

// MARK: - ProductColorPickerViewModelDelegate

extension ProductDetailsViewModel: ProductColorPickerViewModelDelegate {
  func productColorPickerViewModel(didSelectColor color: ProductColor, withIndex index: Int) {
    // TODO: - Handle color change
  }
}

// MARK: - ProductParameterPickerViewModelDelegate

extension ProductDetailsViewModel: ProductParameterPickerViewModelDelegate {
  func productParameterPickerViewModel(_ viewModel: ProductParameterPickerViewModel,
                                       didSelectParameter parameter: ProductParameter,
                                       withIndex index: Int) {
    // TODO: - Handle parameters change
  }
}

// MARK: - ProductPaymentsCountViewModelDelegate

extension ProductDetailsViewModel: ProductPaymentsCountViewModelDelegate {
  func productParameterPickerViewModel(_ viewModel: ProductPaymentsCountViewModel,
                                       didSelectLeasingOption option: LeasingProductInfo,
                                       withIndex index: Int) {
    // TODO: - Handle payments count change
    guard let leasingSum = option.leasingSum, let residualSum = option.residualValue else {
      return
    }
    monthlyPaymentViewModel?.update(leasingSum: leasingSum, residualSum: residualSum, paymentsCount: option.paymentsCount)
  }
}

// MARK: - ProductDeliveryTypeViewModelDelegate

extension ProductDetailsViewModel: ProductDeliveryTypeViewModelDelegate {
  func productDeliveryTypeViewModel(_ viewModel: ProductDeliveryTypeViewModel,
                                    didSelectDeliveryOption option: ProductDeliveryOption,
                                    withIndex index: Int) {
    // TODO: - Handle delivery type change
  }
}

// MARK: - ProductProgramPickerViewModelDelegate

extension ProductDetailsViewModel: ProductProgramPickerViewModelDelegate {
  func productProgramPickerViewModel(_ viewModel: ProductProgramPickerViewModel,
                                     didSetStateOf service: ProductAdditionalService,
                                     withIndex index: Int, isSelected: Bool) {
    // TODO: - Handle service selected
  }
}
