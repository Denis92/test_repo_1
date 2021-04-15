//
//  ClientInfoResponse.swift
//  ForwardLeasing
//

import Foundation

struct ClientInfoResponse: Decodable {
  let previousClientInfo: MaskedClientInfo
}
