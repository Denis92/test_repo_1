//
//  Logger.swift
//  ForwardLeasing
//

import Foundation
import SwiftyBeaver

struct Logger {
  init() {
    guard Constants.enableLoggingToConsole else { return }
    let console = ConsoleDestination()
    console.format = "$M"
    SwiftyBeaver.addDestination(console)
  }

  func verbose(_ message: @autoclosure () -> Any,
               _ file: String = #file,
               _ function: String = #function,
               _ line: Int = #line) {
    guard Constants.enableLoggingToConsole else { return }
    SwiftyBeaver.verbose(message(), file, function, line: line)
  }

  func debug(_ message: @autoclosure () -> Any,
             _ file: String = #file,
             _ function: String = #function,
             _ line: Int = #line) {
    guard Constants.enableLoggingToConsole else { return }
    SwiftyBeaver.debug(message(), file, function, line: line)
  }

  func info(_ message: @autoclosure () -> Any,
            _ file: String = #file,
            _ function: String = #function,
            _ line: Int = #line) {
    guard Constants.enableLoggingToConsole else { return }
    SwiftyBeaver.info(message(), file, function, line: line)
  }

  func warning(_ message: @autoclosure () -> Any,
               _ file: String = #file,
               _ function: String = #function,
               _ line: Int = #line) {
    guard Constants.enableLoggingToConsole else { return }
    SwiftyBeaver.warning(message(), file, function, line: line)
  }

  func error(_ message: @autoclosure () -> Any,
             _ file: String = #file,
             _ function: String = #function,
             _ line: Int = #line) {
    guard Constants.enableLoggingToConsole else { return }
    SwiftyBeaver.error(message(), file, function, line: line)
  }
}

let log = Logger()
