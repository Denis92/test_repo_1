//
//  CheckPaymentError.swift
//  ForwardLeasing
//

import Foundation

enum CheckPaymentError: Error {
  case notConfirmedPayment, pending
}
