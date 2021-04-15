//
//  ProductDetails.swift
//  ForwardLeasing
//

import Foundation

struct ImageInfo: Codable {
  enum ImageType: String, Codable {
    case primary = "PRIMARY", common = "COMMON"
  }
  
  enum CodingKeys: String, CodingKey {
    case imageLink = "imgUrl", type
  }
  
  let type: ImageType
  let imageLink: String
}

struct ProductColor: Codable, Hashable, Equatable {
  let colorCode: String
  let colorName: String
}

struct ProductParameter: Codable {
  enum ParameterType: String, Codable {
    case volume, color
  }
  
  let name: String
  let value: String
  let type: ParameterType
}

struct ProductDeliveryOption: Codable {
  enum CodingKeys: String, CodingKey {
    case type, name, isDefault = "defaultOption"
  }
  
  let type: DeliveryType
  let name: String
  let isDefault: Bool
}

struct LeasingProductInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case paymentsCount = "monthTerm", goodCode, productCode, goodName, leasingSum,
         monthPay, residualValue, earlyUpgradePaymentsCount = "earlyUpgradeTerm", productName,
         freeUpgradePaymentsCount = "freeUpgradeTerm", prolongationPaymentsCount = "prolongationTerm",
         upgradePayment, goodPrice, financialType, productImage, leasingServicePrice = "percentValue"
  }
  var goodCode: String?
  let paymentsCount: Int
  var productCode: String?
  var goodName: String?
  var productName: String?
  var leasingSum: Decimal?
  var monthPay: Decimal?
  var residualValue: Decimal?
  var earlyUpgradePaymentsCount: Int?
  var freeUpgradePaymentsCount: Int?
  var prolongationPaymentsCount: Int?
  var upgradePayment: Decimal?
  var goodPrice: Decimal?
  var financialType: String?
  var productImage: String?
  var leasingServicePrice: Decimal?
  var deliveryInfo: ProductDeliveryOption?

  init(productName: String? = nil, monthPay: Decimal?, productImage: String?) {
    self.paymentsCount = 0
    self.monthPay = monthPay
    self.productName = productName
    self.productImage = productImage
  }
  
  init(paymentsCount: Int, monthPay: Decimal = 3000) {
    self.paymentsCount = paymentsCount
    self.monthPay = monthPay
  }

  init(goodCode: String? = nil, paymentsCount: Int, productCode: String? = nil,
       goodName: String? = nil, productName: String? = nil, leasingSum: Decimal? = nil,
       monthPay: Decimal? = nil, residualValue: Decimal? = nil, earlyUpgradePaymentsCount: Int? = nil,
       freeUpgradePaymentsCount: Int? = nil, prolongationPaymentsCount: Int? = nil,
       upgradePayment: Decimal? = nil, goodPrice: Decimal? = nil, financialType: String? = nil) {
    self.goodCode = goodCode
    self.paymentsCount = paymentsCount
    self.productCode = productCode
    self.goodName = goodName
    self.productName = productName
    self.leasingSum = leasingSum
    self.monthPay = monthPay
    self.residualValue = residualValue
    self.earlyUpgradePaymentsCount = earlyUpgradePaymentsCount
    self.freeUpgradePaymentsCount = freeUpgradePaymentsCount
    self.prolongationPaymentsCount = prolongationPaymentsCount
    self.upgradePayment = upgradePayment
    self.goodPrice = goodPrice
    self.financialType = financialType
  }
}

struct ProductAdditionalService: Codable {
  let name: String
  let price: Decimal
}

struct ProductContentItem: Codable {
  enum CodingKeys: String, CodingKey {
    case code, imageLink = "imageUrl", title, content
  }
  
  let code: String
  let imageLink: String?
  let title: String
  let content: String
}

struct ProductFeature: Codable {
  enum FeatureType: String, Codable {
    case main = "charateristics_main", secondary = "charateristics_secondary", image = "main"
  }
  
  enum CodingKeys: String, CodingKey {
    case title, content, type, imageLink = "imgUrl"
  }
  
  let title: String?
  let content: String?
  let imageLink: String?
  let type: FeatureType
}

struct ProductDetails: Codable {
  enum CodingKeys: String, CodingKey {
    case name, code, images, color, parameters = "params", leasingInfo, additionalServices,
         contentItems = "contentLabel", features, description, shortDescription
  }
  
  let name: String
  let code: String
  let description: String?
  let shortDescription: String?
  // TODO: - Add init with default value
  let images: [ImageInfo]
  let color: ProductColor
  // TODO: - Add init with default value
  let parameters: [ProductParameter]
  let leasingInfo: LeasingProductInfo
  // TODO: - Add init with default value
  let additionalServices: [ProductAdditionalService]
  // TODO: - Add init with default value
  let contentItems: [ProductContentItem]
  // TODO: - Add init with default value
  let features: [ProductFeature]

  // TODO: - update after backend implementation
  let type: ProductType = .smartphone
  
  var primaryImage: URL? {
    guard let imageLink = images.first { $0.type == .primary }?.imageLink else {
      return nil
    }
    return URL(string: imageLink)
  }
  
  // TODO: - Remove stub
  init() {
    self.name = "Apple iPhone SE 64 ГБ\nчёрный"
    // swiftlint:disable:next line_length
//    self.description = "Отдельностоящая стиральная машина FSCR 90420 от производителя бытовой техники Whirlpool. Стиральные машины от компании Whirlpool отличаются невысоким энергопотреблением, низким расходом воды, отличным качеством стирки. Данная модель обладает следующими технологиями: технология 6th Sense, Colours 15&deg;, индикация режимов работы, индикация времени до конца программы, регулировка температуры."
    self.description = nil
    self.shortDescription = nil
    self.code = "ABC123"
    var images: [ImageInfo] = [ImageInfo(type: .common, imageLink: "https://content.forward.lc/files/apple/catalog/iPhone_SE/iPhone_SE_black_1.png"),
                               ImageInfo(type: .primary, imageLink: "https://content.forward.lc/files/apple/catalog/iPhone_SE/iPhone_SE_black_2.png"),
                               ImageInfo(type: .common, imageLink: "https://content.forward.lc/files/apple/catalog/iPhone_SE/iPhone_SE_black_3.png")]
    self.images = images
    self.color = ProductColor(colorCode: "#000000", colorName: "Чёрный")
    self.parameters = [ProductParameter(name: "Объем памяти", value: "64 ГБ", type: .volume)]
    self.leasingInfo = LeasingProductInfo(paymentsCount: 12)
    self.additionalServices = [ProductAdditionalService(name: "Бесплатная замена экрана 1 раз в год", price: 9999)]
    self.contentItems = []
    // swiftlint:disable:next line_length
//    self.features = [ProductFeature(title: "Тип управления", content: "электронное", imageLink: nil, type: .main), ProductFeature(title: "Количество программ", content: "30", imageLink: nil, type: .main), ProductFeature(title: "Максимальная загрузка, кг", content: "10", imageLink: nil, type: .main), ProductFeature(title: "Тип установки", content: "Отдельностоящий", imageLink: nil, type: .main), ProductFeature(title: "Максимальный отжим, об.мин", content: "1400", imageLink: nil, type: .main), ProductFeature(title: nil, content: "Система из камер PRO", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iphone11pro/iphone11pro-camera.png", type: .image), ProductFeature(title: nil, content: "Дисплей Super Retina XDR", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iphone11pro/iphone11pro-screen.png", type: .image), ProductFeature(title: nil, content: "Процессор A13 Bionic", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iphone11pro/iphone11pro-processor.png", type: .image), ProductFeature(title: nil, content: "Защита от воды", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iphone11pro/iphone11pro-water.png", type: .image), ProductFeature(title: nil, content: "Улучшенный Face ID", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iphone11pro/iphone11pro-faceID.png", type: .image), ProductFeature(title: "Тип загрузки", content: "фронтальная", imageLink: nil, type: .secondary), ProductFeature(title: "Тип мотора", content: "direct drive", imageLink: nil, type: .secondary), ProductFeature(title: "Максимальная загрузка (хлопок), кг", content: "10", imageLink: nil, type: .secondary), ProductFeature(title: "Максимальная загрузка (синтетика), кг", content: "3", imageLink: nil, type: .secondary), ProductFeature(title: "Максимальная загрузка (шерсть), кг", content: "2", imageLink: nil, type: .secondary)]
    self.features = [ProductFeature(title: nil, content: "Прочный корпус из алюминия и стекла", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iPhone_SE/1.png", type: .image), ProductFeature(title: nil, content: "Процессор A13 Bionic", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iPhone_SE/2.png", type: .image), ProductFeature(title: nil, content: "Дисплей Retina HD 4.7", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iPhone_SE/3.png", type: .image), ProductFeature(title: nil, content: "Защита от воды", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iPhone_SE/4.png", type: .image), ProductFeature(title: nil, content: "Портретный режим с функцией Smart HDR", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iPhone_SE/5.png", type: .image), ProductFeature(title: nil, content: "Технология Touch ID", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iPhone_SE/6.png", type: .image), ProductFeature(title: nil, content: "Видео 4К", imageLink: "https://content.forward.lc/files/apple/catalog-detail/iPhone_SE/7.png", type: .image)]
  }
}
