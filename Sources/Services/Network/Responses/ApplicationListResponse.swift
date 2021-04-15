//
//  ApplicationListResponse.swift
//  ForwardLeasing
//

import Foundation

struct ApplicationListResponse: Decodable {
  let clientLeasingEntities: [LeasingEntity]
}
