//
//  NetworkService.swift
//  ForwardLeasing
//

import Alamofire
import Foundation
import PromiseKit

enum RequestType {
  case common, authNotRequired, leasingContent
}

struct NetworkConstants {
  static let requestTimeout: TimeInterval = 60
}

protocol NetworkServiceDelegate: class {
  func networkServiceDidEncounterUnauthorizedError(_ networkService: NetworkService)
}

protocol TokenRefreshDelegate: class {
  func networkServiceNeedsTokenRefresh(_ networkService: NetworkService) -> SessionRefreshing?
}

struct ResponseWrapper<T: Decodable>: Decodable {
  enum CodingKeys: String, CodingKey {
    case errorCode, errorMessage, resultData
  }

  let errorCode: Int?
  let errorMessage: String?
  let resultData: T

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    errorCode = try container.decodeIfPresent(Int.self, forKey: .errorCode)
    errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
    if let resultData = try container.decodeIfPresent(T.self, forKey: .resultData) {
      self.resultData = resultData
    } else {
      throw NetworkRequestError.emptyResultData
    }
  }
}

private extension Constants {
  static let invalidPinResultString = "PIN_MISMATCH"
}

class NetworkService: NSObject {
  struct HeaderKeys {
    static let authorization = "Authorization"
    static let bearer = "Bearer"
    static let deviceID = "Device-ID"
    static let deviceType = "Device-Type"
    static let osVersion = "OS-Version"
    static let deviceInfo = "Device-Info"
    static let deviceModel = "Device-Model"
    static let appVersion = "App-Version"
    static let timeZoneOffset = "Timezone-Offset"
  }
  
  private let tokenStorage: TokenStoring
  private let cacheStorage: CacheStorage
  private let logger = RequestLogger()
  private let session: Session
  private lazy var interceptor: Interceptor = {
    let retrier = CustomRequestRetrier()
    retrier.onNeedsToRefreshSession = { [weak self] in
      guard let self = self else {
        return nil
      }
      return self.tokenRefreshDelegate?.networkServiceNeedsTokenRefresh(self)
    }
    let adapter = Adapter { urlRequest, _, completion in completion(.success(urlRequest)) }
    let interceptor = Interceptor(adapter: adapter, retrier: retrier)
    return interceptor
  }()
  
  private var accessToken: String? {
    return tokenStorage.accessToken
  }
  
  var isRefreshingSession = false
  
  weak var delegate: NetworkServiceDelegate?
  weak var tokenRefreshDelegate: TokenRefreshDelegate?
  
  // MARK: - Init
  
  init(tokenStorage: TokenStoring, cacheStorage: CacheStorage = CacheStorage()) {
    self.tokenStorage = tokenStorage
    self.cacheStorage = cacheStorage
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = NetworkConstants.requestTimeout
    configuration.httpShouldSetCookies = false
    configuration.httpCookieAcceptPolicy = .never
    session = Session(configuration: configuration)
    super.init()
  }
  
  // MARK: - Requests
  
  func cachedRequest<T>(requestType: RequestType = .common,
                        method: HTTPMethod,
                        url: String,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = JSONEncoding.default,
                        headers: [String: String] = [:],
                        cacheInfo: CacheInfo) -> Promise<T> where T: Codable {
    if let cache = try? cacheStorage.getCache(ofType: T.self, cacheInfo: cacheInfo) {
      return Promise.value(cache)
    }
    
    return Promise { seal in
      baseRequest(requestType: requestType, method: method, url: url, parameters: parameters,
                  encoding: encoding, headers: headers).done { (result: T) in
                    do {
                      try self.cacheStorage.cacheObject(result, cacheInfo: cacheInfo)
                    } catch {
                      log.debug("Failed to cache url: \(url)")
                    }
                    seal.fulfill(result)
                  }.catch { error in
                    seal.reject(error)
                  }
    }
  }
  
  func baseRequest<T>(requestType: RequestType = .common,
                      method: HTTPMethod,
                      url: String,
                      parameters: Parameters? = nil,
                      encoding: ParameterEncoding = JSONEncoding.default,
                      headers: [String: String] = [:]) -> Promise<T> where T: Decodable {
    if requestType != .authNotRequired, requestType != .leasingContent, accessToken == nil {
      return Promise<T> { seal in
        seal.reject(NetworkRequestError.noToken)
        delegate?.networkServiceDidEncounterUnauthorizedError(self)
      }
    }
    
    let request = createRequest(requestType: requestType, method: method, url: url, parameters: parameters,
                                encoding: encoding, headers: headers)
    let requestData = RequestData.default(DefaultRequestData(requestType: requestType, method: method, url: url,
                                                             parameters: parameters, encoding: encoding))
    return Promise<T> { seal in
      firstly {
        request.responseJSONPromise(logger: self.logger)
      }.then { (json: Any, response: DataResponse<Any, AFError>) -> Promise<T> in
        self.handleResponse(json: json, response: response, request: request, requestType: requestType, requestData: requestData)
      }.done { result in
        seal.fulfill(result)
      }.catch { error in
        var requestError = error
        self.logger.logError(error)
        if NetworkErrorService.isOfflineError(error) {
          requestError = NetworkErrorService.offlineError
        }
        seal.reject(requestError)
      }
    }
  }
  
  // MARK: - Create Request
  
  private func createRequest(requestType: RequestType = .common,
                             method: HTTPMethod,
                             url: String,
                             parameters: Parameters? = nil,
                             encoding: ParameterEncoding = JSONEncoding.default,
                             headers: [String: String] = [:]) -> DataRequest {
    let request = session.request(url,
                                  method: method,
                                  parameters: parameters,
                                  encoding: encoding,
                                  headers: modifiedHeaders(from: headers, requestType: requestType))
    return request
  }
  
  private func modifiedHeaders(from headers: [String: String], requestType: RequestType) -> HTTPHeaders {
    var headers = headers
    if let token = accessToken, requestType != .authNotRequired, requestType != .leasingContent {
      headers[HeaderKeys.authorization] = HeaderKeys.bearer + " " + token
      if let vendorID = Constants.vendorID {
        headers[HeaderKeys.deviceID] = vendorID
      }
      headers[HeaderKeys.osVersion] = Constants.osVersion
      headers[HeaderKeys.deviceInfo] = Constants.deviceName
      headers[HeaderKeys.deviceModel] = Constants.deviceModel
      headers[HeaderKeys.appVersion] = Constants.fullAppVersion
      headers[HeaderKeys.timeZoneOffset] = "\(Constants.timeZoneOffset)"
    }
    headers[HeaderKeys.deviceType] = Constants.deviceType
    return HTTPHeaders(headers)
  }
  
  // MARK: - Response Handler
  
  private func handleResponse<T>(json: Any,
                                 response: DataResponse<Any, AFError>,
                                 request: DataRequest,
                                 requestType: RequestType,
                                 requestData: RequestData) -> Promise<T> where T: Decodable {
    
    var jsonObject: Any? = T.self == EmptyResponse.self && json as? [String: Any] == nil
      ? [:] : json as? [String: Any]
    if let array = json as? [Any] {
      jsonObject = array
    }
    
    return Promise<T> { seal in
      if let code = response.response?.statusCode, let jsonObject = jsonObject {
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        firstly {
          handleSuccessResponse(jsonData: jsonData,
                                statusCode: code,
                                for: request,
                                requestType: requestType,
                                requestData: requestData)
        }.done { response in
          seal.fulfill(response)
        }.catch { error in
          seal.reject(error)
        }
      } else {
        seal.reject(NetworkErrorService.parseError)
      }
    }
  }
  
  private func handleSuccessResponse<T>(jsonData: Data,
                                        statusCode code: Int,
                                        for request: DataRequest,
                                        requestType: RequestType,
                                        requestData: RequestData) -> Promise<T> where T: Decodable {
    let handleErrorResponse: ((Resolver<T>) -> Void) = { seal in
      firstly {
        self.handleErrorResponse(jsonData: jsonData, statusCode: code, for: request,
                                 requestType: requestType, requestData: requestData)
      }.done { result in
        seal.fulfill(result)
      }.catch { error in
        seal.reject(error)
      }
    }
    
    return Promise { seal in
      let statusCode = NetworkErrorService.StatusCode(rawValue: code) ?? NetworkErrorService.StatusCode.internalError
      
      switch statusCode {
      case .okStatus, .okCreated, .okAccepted, .okNoContent:
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customStrategy
        if T.self == EmptyResponse.self {
          let result = try decoder.decode(T.self, from: jsonData)
          seal.fulfill(result)
          return
        }
        if let result = try? decoder.decode(T.self, from: jsonData) {
          seal.fulfill(result)
        }
        do {
          if requestType == .leasingContent {
            let result = try decoder.decode(T.self, from: jsonData)
            seal.fulfill(result)
          } else {
            let result = try decoder.decode(ResponseWrapper<T>.self, from: jsonData)
            if result.errorMessage.isEmptyOrNil {
              seal.fulfill(result.resultData)
            } else {
              handleErrorResponse(seal)
            }
          }
        } catch {
          seal.reject(error)
        }
      default:
        handleErrorResponse(seal)
      }
    }
  }
  
  private func handleErrorResponse<T>(jsonData: Data,
                                      statusCode code: Int,
                                      for request: DataRequest,
                                      requestType: RequestType,
                                      requestData: RequestData) -> Promise<T> where T: Decodable {
    let decoder = JSONDecoder()
    let errorResponse = try? decoder.decode(ErrorResponse.self, from: jsonData)
    let error = NetworkErrorService.error(from: errorResponse, httpCode: code)
    
    if let errorResponse = errorResponse {
      return Promise { seal in
        firstly {
          retryIfNeeded(request: request, requestType: requestType, data: requestData,
                        errorResponse: errorResponse, error: error)
        }.done { result in
          seal.fulfill(result)
        }.catch { error in
          if NetworkErrorService.isUnauthorizedError(error), requestType != .authNotRequired, requestType != .leasingContent {
            self.delegate?.networkServiceDidEncounterUnauthorizedError(self)
          }
          seal.reject(error)
        }
      }
    } else {
      if NetworkErrorService.isUnauthorizedError(error), requestType != .authNotRequired, requestType != .leasingContent {
        delegate?.networkServiceDidEncounterUnauthorizedError(self)
      }
      return Promise(error: error)
    }
  }
}

// MARK: - Download request
extension NetworkService {
  func commonDownloadRequest(requestType: RequestType = .common, url: String) -> Promise<URL> {
    if ![.authNotRequired, .leasingContent].contains(requestType), tokenStorage.accessToken == nil {
      delegate?.networkServiceDidEncounterUnauthorizedError(self)
      return Promise(error: NetworkRequestError.noToken)
    }
    
    return Promise { seal in
      let request = session.download(url, headers: modifiedHeaders(from: [:], requestType: requestType))
      request.response { response in
        let responseStatusCode = response.response?.statusCode
        let statusCode = responseStatusCode.flatMap { NetworkErrorService.StatusCode(rawValue: $0) } ?? .internalError
        switch statusCode {
        case .okStatus, .okCreated, .okAccepted, .okNoContent:
          firstly {
            self.handleDownloadRequestSuccessResponse(result: response.result)
          }.done { url in
            seal.fulfill(url)
          }.catch { error in
            seal.reject(error)
          }
        default:
          firstly {
            self.handleDownloadRequestErrorResponse(response: response, responseStatusCode: responseStatusCode)
          }.done { url in
            seal.fulfill(url)
          }.catch { error in
            seal.reject(error)
          }
        }
      }
    }
  }
  
  private func handleDownloadRequestSuccessResponse(result: Swift.Result<URL?, AFError>) -> Promise<URL> {
    return Promise { seal in
      switch result {
      case .success(let url):
        guard let url = url else {
          seal.reject(NetworkErrorService.parseError)
          return
        }
        seal.fulfill(url)
      case .failure(let error):
        seal.reject(error)
      }
    }
  }
  
  private func handleDownloadRequestErrorResponse(response: AFDownloadResponse<URL?>, responseStatusCode: Int?) -> Promise<URL> {
    return Promise { seal in
      let error: Error
      let decoder = JSONDecoder()
      if let fileURL = response.fileURL,
         let errorResponse = try? decoder.decode(ErrorResponse.self, from: Data(contentsOf: fileURL)) {
        error = NetworkErrorService.error(from: errorResponse, httpCode: responseStatusCode)
      } else {
        error = NetworkErrorService.parseError
      }
      seal.reject(error)
    }
  }
}

// MARK: - Retry request

extension NetworkService {
  private func retryIfNeeded<T>(request: DataRequest,
                                requestType: RequestType,
                                data: RequestData,
                                errorResponse: ErrorResponse,
                                error: Error) -> Promise<T> where T: Decodable {
    return Promise { seal in
      if requestType == .authNotRequired || requestType == .leasingContent {
        seal.reject(error)
        return
      }
      
      let isTokenExpiredError = NetworkErrorService.isUnauthorizedError(error) && errorResponse.isInvalidTokenError
      
      if !isTokenExpiredError, NetworkErrorService.isUnauthorizedError(error) {
        delegate?.networkServiceDidEncounterUnauthorizedError(self)
        seal.reject(error)
      } else if isTokenExpiredError {
        firstly {
          self.retry(request: request, requestType: requestType, data: data, error: error)
        }.done { result in
          seal.fulfill(result)
        }.catch { retryError in
          seal.reject(retryError)
        }
      } else {
        seal.reject(error)
      }
    }
  }
  
  private func retry<T>(request: DataRequest,
                        requestType: RequestType,
                        data: RequestData,
                        error: Error) -> Promise<T> where T: Decodable {
    return Promise { seal in
      self.interceptor.retry(request, for: session, dueTo: error) { retryResult in
        switch retryResult {
        case .doNotRetryWithError(let retryError):
          if NetworkErrorService.isOfflineError(retryError) {
            seal.reject(retryError)
          } else {
            self.delegate?.networkServiceDidEncounterUnauthorizedError(self)
            seal.reject(error)
          }
        case .doNotRetry:
          seal.reject(error)
        case .retry, .retryWithDelay:
          let newRequest = self.convertToDataRequest(data: data)
          firstly {
            newRequest.responseJSONPromise(logger: self.logger)
          }.then { (json: Any, response: DataResponse<Any, AFError>) -> Promise<T> in
            self.handleResponse(json: json, response: response, request: request, requestType: requestType, requestData: data)
          }.done { result in
            seal.fulfill(result)
          }.catch { requestError in
            seal.reject(requestError)
          }
        }
      }
    }
  }
  
  // MARK: - Create new request from request data
  
  private func convertToDataRequest(data: RequestData) -> DataRequest {
    switch data {
    case .default(let requestData):
      return createRequest(requestType: requestData.requestType,
                           method: requestData.method,
                           url: requestData.url,
                           parameters: requestData.parameters,
                           encoding: requestData.encoding)
    }
  }
}

// MARK: - NetworkRequestsCaching

extension NetworkService: NetworkRequestsCaching {
  func invalidateCaches(for cacheInfos: [CacheInfo], groups: [String]) throws {
    try cacheInfos.forEach { try cacheStorage.invalidateCache(cacheInfo: $0) }
    try groups.forEach { try cacheStorage.invalidateGroup(group: $0) }
  }
}
