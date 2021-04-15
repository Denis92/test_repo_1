//
//  NetworkService+Cards.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

extension NetworkService: CardsNetworkProtocol {
  func getCards() -> Promise<[Card]> {
    let result: Promise<CardTemplatesResponse> = baseRequest(method: .get, url: URLFactory.Cards.cardTemplates)
    return result.map(\.cardTemplates)
  }
  
  func deleteCard(with id: String) -> Promise<EmptyResponse> {
    return baseRequest(method: .delete, url: URLFactory.Cards.card(id: id))
  }
}
