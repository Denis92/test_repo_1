//
//  Alamofire+Promise.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit
import Alamofire

struct DataRequestError: Error, LocalizedError {
  let alamofireError: AFError
  let responseHTTPStatusCode: Int?

  var errorDescription: String? {
    return alamofireError.errorDescription
  }
}

typealias JSONReadingOptions = JSONSerialization.ReadingOptions
extension DataRequest {
  typealias ResponseType = (json: Any, response: DataResponse<Any, AFError>)
  func responseJSONPromise(queue: DispatchQueue = .main,
                           options: JSONReadingOptions = .allowFragments,
                           logger: RequestLogger) -> Promise<ResponseType> {
    return Promise { seal in
      let serializer = JSONResponseSerializer(emptyRequestMethods: [.post, .patch, .delete, .head], options: options)
      response(queue: queue, responseSerializer: serializer) { response in
        var multipartData: Data?
        if case .data(let data) = (self as? UploadRequest)?.uploadable {
          multipartData = data
        }
        logger.logRequest(response.request, multipartData: multipartData)
        logger.logDataResponse(response)
        let statusCode = response.response?.statusCode
        switch response.result {
        case .success(let value):
          seal.fulfill((value, response))
        case .failure(let error):
          seal.reject(DataRequestError(alamofireError: error, responseHTTPStatusCode: statusCode))
        }
      }
    }
  }
}
