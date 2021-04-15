//
//  LeasingContentDataSourceMapper.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/15/21.
//

import Foundation

struct LeasingContentDataSourceMapper {
  var leasingContentResponse: LeasingContentResponse
  
  private func transform(modelViewItem item: ViewItem) -> TableSectionViewModel {
    let sectionViewModel = TableSectionViewModel(headerViewModel: nil, footerViewModel: nil)

    let foregroundURL = item.viewItemStyle?.fgURL
  
    let product = Product(code: item.itemCode ?? "",
                          title: item.model?.name,
                          price: (item.model?.favoriteGoods.first?.price).map { String($0) },
                          backgroundColorHEX: item.viewItemStyle?.bgColor ?? "#000000",
                          productImageURL: foregroundURL,
                          size: item.viewItemStyle?.viewStyle ?? .big,
                          alignment: item.viewItemStyle?.viewAlign ?? .top)
    
    let viewModel = SingleProductViewModel(product: product)
    
    sectionViewModel.append(viewModel)
    
    return sectionViewModel
  }
  
  private func transform(bannerViewItem item: ViewItem) -> TableSectionViewModel {
    let sectionViewModel = TableSectionViewModel(headerViewModel: nil, footerViewModel: nil)

    let topLeft = item.banner?.bannerTexts?.first { $0.place == .topLeft }?.text
    let topRight = item.banner?.bannerTexts?.first { $0.place == .topRight }?.text
    let bottomLeft = item.banner?.bannerTexts?.first { $0.place == .bottomLeft }?.text
    let bottomRight = item.banner?.bannerTexts?.first { $0.place == .bottomRight }?.text
    
    let backgroundURL = item.viewItemStyle?.bgURL
    let foregroundURL = item.viewItemStyle?.fgURL
    
    let promo = Promo(code: item.itemCode ?? "",
                      title: item.model?.name ?? "",
                      type: .smartphone)

    let viewModel = ProductPromoViewModel(backgroundImage: backgroundURL ?? "",
                                          foregroundImage: foregroundURL ?? "",
                                          topLeft: topLeft,
                                          topRight: topRight,
                                          centerLeft: nil,
                                          centerRight: nil,
                                          bottomLeft: bottomLeft,
                                          bottomRight: bottomRight,
                                          promo: promo)
    
    sectionViewModel.append(viewModel)
    
    return sectionViewModel
  }
  
  private func transform(viewItem item: ViewItem) -> [TableSectionViewModel] {
    switch item.type {
    case .category:
      guard let childItems = item.childItems else { return [] }
      return childItems.flatMap { transform(viewItem: $0) }
    case .model:
      return [transform(modelViewItem: item)]
    case .banner:
      return [transform(bannerViewItem: item)]
    default:
      return []
    }
  }
  
  func transform() -> [TableSectionViewModel] {
    var result: [TableSectionViewModel] = []
    
    for item in leasingContentResponse.content {
      result.append(contentsOf: transform(viewItem: item))
    }
    
    return result
  }
}
