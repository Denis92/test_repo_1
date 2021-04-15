//
//  CategoryDetailsViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol CategoryDetailsViewModelDelegate: class {
  func categoryDetailsViewModel(_ viewModel: CategoryDetailsViewModel, didRequestChangeFilters filters: [Filter],
                                colorFilters: [ColorFilter])
  func categoryDetailsViewModel(_ viewModel: CategoryDetailsViewModel, didRequestShowProductDetails product: Product)
  func categoryDetailsViewModel(_ viewModel: CategoryDetailsViewModel,
                                didRequestSelectSubcategory currentSubcategory: Subcategory?,
                                allSubcategories: [Subcategory])
}

class CategoryDetailsViewModel: CommonTableViewModel, BindableViewModel {
  // MARK: - Properties
  var screenTitle: String? {
    return category?.title
  }
  
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidLoadData: (() -> Void)?
  
  var onDidUpdateFilterButtonVisibility: ((_ isVisible: Bool) -> Void)?
  
  var isFilterButtonVisible: Bool {
    didSet {
      if isFilterButtonVisible != oldValue {
        onDidUpdateFilterButtonVisibility?(isFilterButtonVisible)
      }
    }
  }
  
  weak var delegate: CategoryDetailsViewModelDelegate?
  
  private (set) var sectionViewModels: [TableSectionViewModel] = []
  private (set) var headerViewModel: SelectSubcategoryHeaderViewModel
  
  private var subcategories: [Subcategory] = []
  private var selectedSubcategory: Subcategory?
  private var filters: [Filter] = []
  private var colorFilters: [ColorFilter] = []
  
  private let category: Category?
  
  // MARK: - Init
  
  init(flow: CategoryDetailsFlow) {
    self.category = flow.category
    var subcategory: Subcategory?
    switch flow {
    case .default(let configuration):
      isFilterButtonVisible = configuration.subcategory != nil
      subcategory = configuration.subcategory
    default:
      isFilterButtonVisible = false
    }
    headerViewModel = SelectSubcategoryHeaderViewModel(selectedSubcategory: subcategory)
    headerViewModel.delegate = self
  }
  
  // MARK: - Public methods
  
  func loadData() {
    // TODO: load real data
//    onDidStartRequest?()
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//      self.onDidFinishRequest?()
//      self.populateSubcategories()
//      self.populateFilters()
//      self.populateColorFilters()
//      self.populateItems()
//      self.onDidLoadData?()
//    }
  }
  
  func update(selectedSubcategory subcategory: Subcategory?) {
    guard selectedSubcategory != subcategory else {
      return
    }
    isFilterButtonVisible = subcategory != nil
    selectedSubcategory = subcategory
    headerViewModel.update(subcategory: subcategory)
    sectionViewModels = []
    onDidLoadData?()
    loadData()
  }
  
  func update(filters: [Filter], colorFilters: [ColorFilter]) {
    self.filters = filters
    self.colorFilters = colorFilters
    loadData()
  }
  
  func changeFilters() {
    delegate?.categoryDetailsViewModel(self, didRequestChangeFilters: filters, colorFilters: colorFilters)
  }
  
  // MARK: - Private methods
  
  private func populateItems() {
//    sectionViewModels = []
//    let sectionViewModel = TableSectionViewModel()
//    sectionViewModels.append(sectionViewModel)
//
//    let iphoneSE = "https://content.forward.lc/files/apple/catalog/iPhone_SE/iPhone_SE_black_2.png"
//    let currencyFormatter = NumberFormatter.currencyFormatter(withSymbol: true)
//    let iphoneSESumm = currencyFormatter.string(from: Amount(integerLiteral: 2932)) ?? ""
//
//    let iphone11 = "https://content.forward.lc/files/apple/catalog/iPhone_11/Red/iPhone_11_R_0.png"
//    let iphone11Summ = currencyFormatter.string(from: Amount(integerLiteral: 3688)) ?? ""
//
//    let acerSwift3 = "https://content.forward.lc/files/acer/catalog/Swift_3_SF313_52/1.png"
//    let acerSwift3Summ = currencyFormatter.string(from: Amount(integerLiteral: 2284)) ?? ""
//
//    let acerConceptD3 = "https://content.forward.lc/files/acer/catalog/ConceptD_3_CN315_71_76T2/1.png"
//    let acerConceptD3Summ = currencyFormatter.string(from: Amount(integerLiteral: 5523)) ?? ""
//
//    let whirlpool = "https://static-eu.insales.ru/images/products/1/2427/214116731/fscr_90420-600x600.jpg"
//    let whirlpoolSumm = currencyFormatter.string(from: Amount(integerLiteral: 1060)) ?? ""
//
//    let hotpoint = "https://static-eu.insales.ru/images/products/1/3163/317312091/F095738_1000x1000_frontal.jpg"
//    let hotpointSumm = currencyFormatter.string(from: Amount(integerLiteral: 2611)) ?? ""
//
//    let xbox = "https://content.forward.lc/files/ds/xlg.png"
//    let xboxSumm = currencyFormatter.string(from: Amount(integerLiteral: 299)) ?? ""
//
//    let singleProductCell1: SingleProductViewModel
//    let singleProductCell2: SingleProductViewModel
//    // swiftlint:disable:next line_length
//    switch category?.title {
//    case "iPhone":
//      // swiftlint:disable:next line_length
//      singleProductCell1 = SingleProductViewModel(product: Product(code: "Apple_iPhone_SE", title: "iPhone SE", price: iphoneSESumm, backgroundColorHEX: "74EAC0", productImageURL: iphoneSE, type: .smartphone))
//      // swiftlint:disable:next line_length
//      singleProductCell2 = SingleProductViewModel(product: Product(code: "Apple_iPhone_11", title: "iPhone 11", price: iphone11Summ, backgroundColorHEX: "74EAC0", productImageURL: iphone11, type: .smartphone))
//    case "ноутбуки":
//      // swiftlint:disable:next line_length
//      singleProductCell1 = SingleProductViewModel(product: Product(code: "Acer_Swift", title: "Swift 3", price: acerSwift3Summ, backgroundColorHEX: "FFF5BC", productImageURL: acerSwift3, type: .notebook))
//      // swiftlint:disable:next line_length
//      singleProductCell2 = SingleProductViewModel(product: Product(code: "Acer_Concept", title: "ConceptD 3", price: acerConceptD3Summ, backgroundColorHEX: "FFF5BC", productImageURL: acerConceptD3, type: .notebook))
//    case "бытовая техника":
//      // swiftlint:disable:next line_length
//      singleProductCell1 = SingleProductViewModel(product: Product(code: "Whirlpool", title: "FSCR 90420", price: whirlpoolSumm, backgroundColorHEX: "EDBDFF", productImageURL: whirlpool, type: .appliances))
//      // swiftlint:disable:next line_length
//      singleProductCell2 = SingleProductViewModel(product: Product(code: "Hotpoint", title: "CM 9945 HA", price: hotpointSumm, backgroundColorHEX: "EDBDFF", productImageURL: hotpoint, type: .appliances))
//    default:
//      singleProductCell1 = SingleProductViewModel(product: Product(code: "Xbox", title: "Xbox LIVE: GOLD", price: xboxSumm, backgroundColorHEX: "9BD4FF", productImageURL: xbox, type: .service))
//      // swiftlint:disable:next line_length
//      singleProductCell2 = SingleProductViewModel(product: Product(code: "Xbox", title: "Xbox LIVE: GOLD", price: xboxSumm, backgroundColorHEX: "9BD4FF", productImageURL: xbox, type: .service))
//    }
//
//    // swiftlint:disable:next line_length
//    singleProductCell1.delegate = self
//    sectionViewModel.append(singleProductCell1)
//    // swiftlint:disable:next line_length
//    singleProductCell2.delegate = self
//    sectionViewModel.append(singleProductCell2)
//
//    if category?.title == "iPhone" {
//      // swiftlint:disable:next line_length
//      let galaxy = "https://content.forward.lc/files/apple/catalog/iPhone_11/Red/iPhone_11_R_3.png"
//      // swiftlint:disable:next line_length
//      let background = "https://www.winsornewton.com/na/wp-content/uploads/sites/50/2019/09/50903849-WN-ARTISTS-OIL-COLOUR-SWATCH-WINSOR-EMERALD-960x960.jpg"
//      let promoCell = ProductPromoViewModel(backgroundImage: background, foregroundImage: galaxy,
//                                            topLeft: "КАМЕРА ЛУЧШЕ", topRight: "ЧЕМ У IPHONE X", centerLeft: nil,
//                                            centerRight: nil, bottomLeft: "IPHONE 11", bottomRight: "ОТ \(iphone11Summ).",
//                                            promo: Promo(code: "MX9R2RU~A", title: nil, type: .smartphone))
//      promoCell.delegate = self
//      sectionViewModel.append(promoCell)
//    }
  }
  
//  private func populateSubcategories() {
//    guard subcategories.isEmpty else {
//      return
//    }
//    let sub1 = Subcategory(code: UUID().uuidString, title: "стиральные машины")
//    let sub2 = Subcategory(code: UUID().uuidString, title: "посудомоечные машины")
//    let sub3 = Subcategory(code: UUID().uuidString, title: "холодильники")
//    let sub4 = Subcategory(code: UUID().uuidString, title: "духовые шкафы")
//    let sub5 = Subcategory(code: UUID().uuidString, title: "варочные панели")
//    let sub6 = Subcategory(code: UUID().uuidString, title: "микроволновые печи")
//    let sub7 = Subcategory(code: UUID().uuidString, title: "варочные панели")
//    let sub8 = Subcategory(code: UUID().uuidString, title: "вытяжные шкафы")
//    let sub9 = Subcategory(code: UUID().uuidString, title: "кофемашины")
//    subcategories = [sub1, sub2, sub3, sub4, sub5, sub6, sub7, sub8, sub9]
//  }
  
//  private func populateFilters() {
//    guard filters.isEmpty else {
//      return
//    }
//
//    let filter1 = Filter(filterType: .singleOptionOnly, title: "Встраеваемая",
//                         options: [FilterOption(title: "Да"),
//                                   FilterOption(title: "Нет")])
//    let filter2 = Filter(filterType: .multipleOptions, title: "Загрузка, кг",
//                         options: [FilterOption(title: "12"),
//                                   FilterOption(title: "10"),
//                                   FilterOption(title: "8"),
//                                   FilterOption(title: "5"),
//                                   FilterOption(title: "4"),
//                                   FilterOption(title: "3")])
//    let filter3 = Filter(filterType: .multipleOptions, title: "Ширина, см",
//                         options: [FilterOption(title: "59,5"),
//                                   FilterOption(title: "60")])
//    let filter4 = Filter(filterType: .multipleOptions, title: "Глубина, см",
//                         options: [FilterOption(title: "42,5"),
//                                   FilterOption(title: "44"),
//                                   FilterOption(title: "45,5"),
//                                   FilterOption(title: "47,5"),
//                                   FilterOption(title: "54,5"),
//                                   FilterOption(title: "60.5")])
//    filters = [filter1, filter2, filter3, filter4]
//  }
//
//  private func populateColorFilters() {
//    guard colorFilters.isEmpty else { return }
//    colorFilters = [ColorFilter(title: "Цвет корпуса",
//                                options: [ColorFilterOption(color: ProductColor(colorCode: "FF0000", colorName: "Красный"),
//                                                            isSelected: false),
//                                          ColorFilterOption(color: ProductColor(colorCode: "00FF00", colorName: "Зелёный"),
//                                                            isSelected: false),
//                                          ColorFilterOption(color: ProductColor(colorCode: "0000FF", colorName: "Синий"),
//                                                            isSelected: false)])]
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

// MARK: - SingleProductViewModelDelegate

extension CategoryDetailsViewModel: SingleProductViewModelDelegate {
  func singleProductViewModel(_ viewModel: SingleProductViewModel, didSelectProduct product: Product) {
    delegate?.categoryDetailsViewModel(self, didRequestShowProductDetails: product)
  }
}

// MARK: - ProductPromoViewModelDelegate

extension CategoryDetailsViewModel: ProductPromoViewModelDelegate {
  func productPromoViewModel(_ viewModel: ProductPromoViewModel, didSelectPromo promo: Promo) {
    // TODO: navigate via deeplink
  }
}

// MARK: - CategoryDetailsSelectSubcategoryViewModelDelegate

extension CategoryDetailsViewModel: SelectSubcategoryHeaderViewModelDelegate {
  func selectSubcategoryHeaderViewModel(_ viewModel: SelectSubcategoryHeaderViewModel,
                                        didRequestChooseSubcategoryWithCurrent selectedSubcategory: Subcategory?) {
    delegate?.categoryDetailsViewModel(self, didRequestSelectSubcategory: selectedSubcategory, allSubcategories: subcategories)
  }
}
