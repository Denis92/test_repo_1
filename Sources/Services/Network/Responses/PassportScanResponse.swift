//
//  PassportScanResponse.swift
//  ForwardLeasing
//

import Foundation

struct PassportScanResponse: Decodable {
  let documentData: DocumentData?
  let application: LeasingEntity
  let applicationStatus: LeasingEntityStatus?
  let checkResultText: String?
}
