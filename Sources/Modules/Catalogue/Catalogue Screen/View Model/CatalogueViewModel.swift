//
//  CatalogueViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol CatalogueViewModelDelegate: class {
  func catalogueViewModel(_ viewModel: CatalogueViewModel, didRequestShowCategoryDetails category: Category,
                          subcategory: Subcategory?)
  func catalogueViewModel(_ viewModel: CatalogueViewModel, didRequestShowProductDetails product: Product)
  func catalogueViewModel(_ viewModel: CatalogueViewModel,
                          didSelectSubscriptionProduct subscriptionProduct: SubscriptionProduct,
                          withSubcriptionItem subscriptionItem: SubscriptionProductItem)
}

class CatalogueViewModel: CommonTableViewModel, BindableViewModel {
  typealias Dependencies = HasLeasingContentService

  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidLoadData: (() -> Void)?

  weak var delegate: CatalogueViewModelDelegate?

  private (set) var topCollectionViewModel: CatalogueTopCollectionViewModel?
  private (set) var sectionViewModels: [TableSectionViewModel] = []
  
  private let dependencies: Dependencies
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  func loadData() {
    // TODO: load real data
    onDidStartRequest?()

    dependencies.leasingContentService.getMainpageData().done { [weak self] response in
      let mapper = LeasingContentDataSourceMapper(leasingContentResponse: response)
      self?.sectionViewModels.append(contentsOf: mapper.transform())
      self?.onDidLoadData?()
      self?.onDidFinishRequest?()
    }.catch { err in
      print("Error. \(err)")
    }
    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//      self.onDidFinishRequest?()
//      self.onDidLoadData?()
//    }
  }

//  private func populateNavigationCollectionData() {
//    // swiftlint:disable:next line_length
//    let url1 = "https://subscribe-rf-front-test.forward.lc/f/general/media/categories/phones_apple.png"
//    let item1 = CatalogueNavigationItem(type: .category, name: "iPhone", imageURL: url1, colorHEX: "74EAC0")
//    let url2 = "https://subscribe-rf-front-test.forward.lc/f/general/media/categories/notebooks.png"
//    let item2 = CatalogueNavigationItem(type: .category, name: "Ноутбуки", imageURL: url2, colorHEX: "FFF5BC")
//    let url3 = "https://subscribe-rf-front-test.forward.lc/f/general/media/categories/appliances.png"
//    let item3 = CatalogueNavigationItem(type: .category, name: "Бытовая техника", imageURL: url3, colorHEX: "EDBDFF")
//    // swiftlint:disable:next line_length
//    let url4 = "https://subscribe-rf-front-test.forward.lc/f/general/media/categories/digital_services.png"
//    let item4 = CatalogueNavigationItem(type: .subscription, name: "Удивительные подписки", imageURL: url4, colorHEX: "9BD4FF")
//
//    topCollectionViewModel = CatalogueTopCollectionViewModel(navigationItems: [item1, item2, item3, item4])
//    topCollectionViewModel?.delegate = self
//  }

  // swiftlint:disable:next function_body_length
//  private func populateItems() {
//    sectionViewModels = []
//
//    // swiftlint:disable:next line_length
//    let iphone = "https://content.forward.lc/files/apple/catalog/iPhone_SE/iPhone_SE_black_2.png"
//    let currencyFormatter = NumberFormatter.currencyFormatter(withSymbol: true)
//    let summ = currencyFormatter.string(from: Amount(integerLiteral: 2932)) ?? ""
//
//    let header = CatalogueListHeaderViewModel(category: Category(code: "phones_apple", title: "iPhone", imageURL: nil))
//    let sectionViewModel1 = TableSectionViewModel(headerViewModel: header)
//    sectionViewModels.append(sectionViewModel1)
//
//    // swiftlint:disable:next line_length
//    let singleProductCell1 = SingleProductViewModel(product: Product(code: "iphone", title: "Apple iPhone SE 64 ГБ", price: summ, backgroundColorHEX: "#74EAC0", productImageURL: iphone, type: .smartphone))
//    singleProductCell1.delegate = self
//    sectionViewModel1.append(singleProductCell1)
//    // swiftlint:disable:next line_length
//    let singleProductCell2 = SingleProductViewModel(product: Product(code: "iphone", title: "Apple iPhone SE 64 ГБ", price: summ, backgroundColorHEX: "#74EAC0", productImageURL: iphone, type: .smartphone))
//    singleProductCell2.delegate = self
//    sectionViewModel1.append(singleProductCell2)
//
//    // swiftlint:disable:next line_length
//    let galaxy = "https://content.forward.lc/files/apple/catalog/iPhone_11/Red/iPhone_11_R_3.png"
//    // swiftlint:disable:next line_length
//    let background = "https://www.winsornewton.com/na/wp-content/uploads/sites/50/2019/09/50903849-WN-ARTISTS-OIL-COLOUR-SWATCH-WINSOR-EMERALD-960x960.jpg"
//    let promoCell = ProductPromoViewModel(backgroundImage: background, foregroundImage: galaxy,
//                                          topLeft: "КАМЕРА ЛУЧШЕ", topRight: "ЧЕМ У IPHONE X", centerLeft: nil,
//                                          centerRight: nil, bottomLeft: "IPHONE SE", bottomRight: "ОТ \(summ)",
//                                          promo: Promo(code: "MX9R2RU~A", title: nil, type: .smartphone))
//    promoCell.delegate = self
//    sectionViewModel1.append(promoCell)
//    let allPhonesButton = ShowCategoryDetailsButtonViewModel(title: "Все смартфоны Apple")
//    allPhonesButton.delegate = self
//    sectionViewModel1.append(allPhonesButton)
//
//    let header2 = CatalogueListHeaderViewModel(category: Category(code: "appliances", title: "Бытовая техника", imageURL: nil))
//    let sectionViewModel2 = TableSectionViewModel(headerViewModel: header2)
//    sectionViewModels.append(sectionViewModel2)
//
//    // swiftlint:disable:next line_length
//    let washingMachine = "https://static-eu.insales.ru/images/products/1/409/271466905/front.washer.white-re.png"
//    // swiftlint:disable:next line_length
//    let dishwasher = "https://static-eu.insales.ru/images/products/1/3274/214117578/wif_4043_dlgt_e_1-600x600.jpg"
//    // swiftlint:disable:next line_length
//    let fridge = "https://static-eu.insales.ru/images/products/1/3259/214117563/wtnf__923__w_1-600x600.jpg"
//    // swiftlint:disable:next line_length
//    let oven = "https://static-eu.insales.ru/images/products/1/818/317309746/ge-data-mx-duhovye-shkafy-2bf_dukhovoy_shkaf_kitchen_aid_kolsp_60600_thumb_600x600-1000x1000.jpg"
//    // swiftlint:disable:next line_length
//    let hob = "https://static-eu.insales.ru/images/products/1/3106/214117410/goa_6425_nb-600x600.jpg"
//    let subcategories = [("Стиральные машины", washingMachine),
//                         ("Посудомоечные машины", dishwasher),
//                         ("Холодильники", fridge),
//                         ("Духовые шкафы", oven),
//                         ("Варочные поверхности", hob)].map { return Subcategory(code: "qwe", title: $0.0, imageURL: $0.1) }
//    let subcategoryViewModel = SubcategoryListViewModel(subcategoriesList: subcategories)
//    subcategoryViewModel.delegate = self
//    sectionViewModel2.append(subcategoryViewModel)
//
//    // swiftlint:disable:next line_length
//    let product1 = Product(code: "washingMachine", title: "Стиральная машина Whirlpool FSCR 90420", price: "1 060 ₽", backgroundColorHEX: "#EDBDFF", productImageURL: washingMachine, type: .appliances)
//    // swiftlint:disable:next line_length
//    let product2 = Product(code: "dishwasher", title: "Посудомоечная машина Whirlpool WIF 4043 DLGT E", price: "1 472 ₽", backgroundColorHEX: "#EDBDFF", productImageURL: dishwasher, type: .appliances)
//    let productPair = ProductPairViewModel(productPair: (product1, product2))
//    productPair.delegate = self
//    let sectionViewModel3 = TableSectionViewModel()
//    sectionViewModel3.append(productPair)
//    sectionViewModels.append(sectionViewModel3)
//
//    let header4 = CatalogueListHeaderViewModel(category: Category(code: "subscriptions", title: "Сервисы", imageURL: nil))
//    let sectionViewModel4 = TableSectionViewModel(headerViewModel: header4)
//    sectionViewModels.append(sectionViewModel3)
//
//    let subscriptionItems: [SubscriptionProductItem] = [
//      SubscriptionProductItem(id: "1",
//                              price: "1 200 ₽",
//                              months: 3,
//                              imageURLs: ["https://cdn1.ozone.ru/s3/multimedia-2/c1200/6007982930.jpg"],
//                              description: "",
//                              contentLabels: [],
//                              sortOrder: 0,
//                              hexColor: "FFF4BC"),
//      SubscriptionProductItem(id: "2",
//                              price: "1 500 ₽",
//                              months: 6,
//                              imageURLs: ["https://cdn1.ozone.ru/s3/multimedia-a/c1200/6007982974.jpg"],
//                              description: "",
//                              contentLabels: [],
//                              sortOrder: 1,
//                              hexColor: "EDBCFF"),
//      SubscriptionProductItem(id: "3",
//                              price: "1 800 ₽",
//                              months: 12,
//                              imageURLs: ["https://cdn1.ozone.ru/s3/multimedia-4/c1200/6010498180.jpg"],
//                              description: "",
//                              contentLabels: [],
//                              sortOrder: 1,
//                              hexColor: "9BD4FF")
//    ]
//    let subscription = SubscriptionProduct(name: "Карта оплаты Xbox Game Pass", items: subscriptionItems)
//    sectionViewModel4.append(contentsOf: makeSubscriptionProductViewModels(from: [subscription]))
//    sectionViewModels.append(sectionViewModel4)
//  }
//
//  private func makeSubscriptionProductViewModels(from subscriptionProducts: [SubscriptionProduct]) -> [SubscriptionProductViewModel] {
//    return subscriptionProducts.map { subscriptionProduct in
//      SubscriptionProductViewModel(from: subscriptionProduct) { [weak self] item in
//        guard let self = self else { return }
//        self.delegate?.catalogueViewModel(self, didSelectSubscriptionProduct: subscriptionProduct,
//                                          withSubcriptionItem: item)
//      }
//    }
//  }

  private func indexPath(for viewModel: CommonTableCellViewModel & AnyObject) -> IndexPath? {
    for (sectionIndex, section) in sectionViewModels.enumerated() {
      if let index = section.index(of: viewModel) {
        return IndexPath(row: index, section: sectionIndex)
      }
    }
    return nil
  }
}

// MARK: - CatalogueTopCollectionViewModelDelegate

extension CatalogueViewModel: CatalogueTopCollectionViewModelDelegate {
  func catalogueTopCollectionViewModel(_ viewModel: CatalogueTopCollectionViewModel,
                                       didSelectItem item: CatalogueNavigationItem) {
    switch item.type {
    case .model:
      delegate?.catalogueViewModel(self, didRequestShowProductDetails: Product(navigationItem: item))
    case .category:
      delegate?.catalogueViewModel(self, didRequestShowCategoryDetails: Category(navigationItem: item),
                                   subcategory: nil)
    default:
      delegate?.catalogueViewModel(self, didRequestShowCategoryDetails: Category(navigationItem: item),
                                   subcategory: nil)
      break
    }
  }
}

// MARK: - SingleProductViewModelDelegate

extension CatalogueViewModel: SingleProductViewModelDelegate {
  func singleProductViewModel(_ viewModel: SingleProductViewModel, didSelectProduct product: Product) {
    delegate?.catalogueViewModel(self, didRequestShowProductDetails: product)
  }
}

// MARK: - ProductPairViewModelDelegate

extension CatalogueViewModel: ProductPairViewModelDelegate {
  func productPairViewModel(_ viewModel: ProductPairViewModel, didSelectProduct product: Product) {
    delegate?.catalogueViewModel(self, didRequestShowProductDetails: product)
  }
}

// MARK: - ProductPromoViewModelDelegate

extension CatalogueViewModel: ProductPromoViewModelDelegate {
  func productPromoViewModel(_ viewModel: ProductPromoViewModel, didSelectPromo promo: Promo) {
    // TODO: navigate via deeplink
  }
}

// MARK: - ShowCategoryDetailsButtonViewModelDelegate

extension CatalogueViewModel: ShowCategoryDetailsButtonViewModelDelegate {
  func showCategoryDetailsButtonViewModelDidRequestShowCategory(_ viewModel: ShowCategoryDetailsButtonViewModel) {
    guard let indexPath = indexPath(for: viewModel), let section = sectionViewModels.element(at: indexPath.section),
          let headerViewModel = section.headerViewModel as? CatalogueListHeaderViewModel else {
      return
    }
    delegate?.catalogueViewModel(self, didRequestShowCategoryDetails: headerViewModel.category, subcategory: nil)
  }
}

// MARK: - SubcategoryListViewModelDelegate

extension CatalogueViewModel: SubcategoryListViewModelDelegate {
  func subcategoryListViewModel(_ viewModel: SubcategoryListViewModel, didSelectSubcategory subcategory: Subcategory) {
    guard let indexPath = indexPath(for: viewModel), let section = sectionViewModels.element(at: indexPath.section),
          let headerViewModel = section.headerViewModel as? CatalogueListHeaderViewModel else {
      return
    }
    delegate?.catalogueViewModel(self, didRequestShowCategoryDetails: headerViewModel.category, subcategory: subcategory)
  }
}
