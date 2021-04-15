//
//  RequestData.swift
//  ForwardLeasing
//

import Alamofire

enum RequestData {
  case `default`(DefaultRequestData)
}

struct DefaultRequestData {
  let requestType: RequestType
  let method: HTTPMethod
  let url: String
  let parameters: Parameters?
  let encoding: ParameterEncoding
}
