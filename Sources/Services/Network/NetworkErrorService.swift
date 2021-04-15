//
//  NetworkErrorService.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let AlamofireNoInternetErrorCode = 13
}

enum TokenRefreshError: Error, CaseIterable {
  case refreshInProgress, noData, refreshNotPossible, refreshNotNeeded, cancelled
}

extension TokenRefreshError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .cancelled:
      return R.string.networkErrors.errorTokenRefreshDenied()
    default:
      return nil
    }
  }
}

enum NetworkRequestError: Error, LocalizedError {
  case noToken, couldNotExtractToken, invalidPin, emptyResultData

  var errorDescription: String? {
    switch self {
    case .noToken:
      return R.string.networkErrors.errorNoTokenText()
    case .couldNotExtractToken:
      return R.string.networkErrors.errorCouldNotExtractTokenText()
    case .invalidPin:
      return R.string.networkErrors.errorInvalidPinText()
    case .emptyResultData:
      return nil
    }
  }
}

struct CustomServerError: Error, LocalizedError {
  enum ErrorType {
    case unknown, otherApplicationActive, basketInvalid, passportDataInvalid, applicationNotFound, numberOfRequestsExceeded
  }

  let httpCode: Int?
  let code: Int?
  let errorDescription: String?
  var errorType: ErrorType {
    switch code {
    case 2105:
      return .otherApplicationActive
    case 2175:
      return .basketInvalid
    case 1400:
      return .passportDataInvalid
    case 2110:
      return .applicationNotFound
    case 2210:
      return .numberOfRequestsExceeded
    default:
      return .unknown
    }
  }
}

class NetworkErrorService: NSObject {
  enum StatusCode: Int {
    case okStatus = 200
    case okCreated = 201
    case okAccepted = 202
    case okNoContent = 204
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case conflict = 409
    case internalError = 500
    case badGateway = 502
  }

  enum ErrorCode: Int {
    case custom = 1001
  }

  static let networkErrorDomain = "ForwardLeasingNetworkError"

  static let offlineError: Error = {
    let message = R.string.networkErrors.errorNoInternetText()
    let userInfo = [NSLocalizedDescriptionKey: message]
    return NSError(domain: networkErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: userInfo) as Error
  }()

  static let requestCreationError: Error = {
    let userInfo = [NSLocalizedDescriptionKey: R.string.networkErrors.errorCreatingRequestDataText()]
    return NSError(domain: networkErrorDomain, code: 0, userInfo: userInfo) as Error
  }()

  static let parseError: Error = {
    let userInfo = [NSLocalizedDescriptionKey: R.string.networkErrors.errorParsingText()]
    return NSError(domain: networkErrorDomain, code: 0, userInfo: userInfo) as Error
  }()

  static func error(from errorResponse: ErrorResponse?, httpCode: Int?) -> Error {
    let message = errorMessage(from: errorResponse)
    let code = errorResponse?.errorCode ?? 0
    let error = CustomServerError(httpCode: httpCode, code: code, errorDescription: message)
    return error
  }
  
  static private func errorMessage(from errorResponse: ErrorResponse?) -> String {
    if let message = errorResponse?.errorMessage, !message.isEmpty {
      return message
    }
    guard let errorCode = errorResponse?.errorCode else { return R.string.networkErrors.errorUnknownText() }
    switch errorCode {
    case 2210:
      return R.string.networkErrors.errorNumberOfRquestsExceeded()
    default:
      return R.string.networkErrors.errorUnknownText()
    }
  }

  static func isUnauthorizedError(_ error: Error) -> Bool {
    if let dataRequestError = error as? DataRequestError,
      dataRequestError.responseHTTPStatusCode == StatusCode.unauthorized.rawValue {
      return true
    }
    if let customError = error as? CustomServerError {
      return customError.httpCode == StatusCode.unauthorized.rawValue 
    }
    return (error as NSError).code == StatusCode.unauthorized.rawValue
  }

  static func isOfflineError(_ error: Error) -> Bool {

    let errorCodes = [NSURLErrorNotConnectedToInternet, NSURLErrorCannotConnectToHost, NSURLErrorTimedOut,
                      NSURLErrorCannotFindHost, NSURLErrorCallIsActive, NSURLErrorNetworkConnectionLost,
                      NSURLErrorDataNotAllowed, NSURLErrorCannotLoadFromNetwork,
                      NSURLErrorInternationalRoamingOff, NSURLErrorSecureConnectionFailed,
                      Constants.AlamofireNoInternetErrorCode]
    if let dataRequestError = error as? DataRequestError {
      let afError = dataRequestError.alamofireError
      if let underlyingError = afError.underlyingError {
        return errorCodes.contains((underlyingError as NSError).code)
      }
      return errorCodes.contains((afError as NSError).code)
    }

    return errorCodes.contains((error as NSError).code)
  }
}
