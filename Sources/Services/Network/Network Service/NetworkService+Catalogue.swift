//
//  NetworkService+Catalogue.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

extension NetworkService: CatalogueNetworkProtocol {
  func getProductInfo(productCode: String) -> Promise<ProductInfoResponse> {
    return baseRequest(method: .get, url: URLFactory.Catalogue.productInfo(productCode: productCode))
  }

  func getGoods(with modelCode: String) -> Promise<ModelGoodsResponse> {
    return baseRequest(method: .get, url: URLFactory.Catalogue.goods(modelCode: modelCode))
  }
}
