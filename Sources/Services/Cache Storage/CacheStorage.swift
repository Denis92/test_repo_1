//
//  CacheStorage.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let storageFolderName = "ForwardLeasingCacheStorage"
}

private struct CacheItem<T: Codable>: Codable {
  let object: T
  let expires: Date
}

enum CacheStorageError: Error {
  case couldNotSaveFile, cacheExpired, noDataSaved
}

protocol CacheInfo {
  var key: String { get }
  var cacheTime: TimeInterval { get }
  static var group: String { get }
  var itemGroup: String { get }
}

extension CacheInfo {
  static var group: String {
    return String(describing: self)
  }
  
  var itemGroup: String {
    return Self.group
  }
}

class CacheStorage {
  private let fileManager = FileManager.default
  private let folderName: String = Constants.storageFolderName
  
  func cacheObject<T: Codable>(_ object: T, cacheInfo: CacheInfo) throws {
    let fileURL = try makeFileURL(fileName: cacheInfo.key, group: cacheInfo.itemGroup)
    let storageItem = CacheItem(object: object, expires: Date(timeIntervalSinceNow: cacheInfo.cacheTime))
    let data = try JSONEncoder().encode(storageItem)
    
    if fileManager.fileExists(atPath: fileURL.path) {
      try fileManager.removeItem(at: fileURL)
    }
    
    guard fileManager.createFile(atPath: fileURL.path, contents: data) else {
      throw CacheStorageError.couldNotSaveFile
    }
  }
  
  func getCache<T: Codable>(ofType: T.Type, cacheInfo: CacheInfo) throws -> T {
    let fileURL = try makeFileURL(fileName: cacheInfo.key, group: cacheInfo.itemGroup)
    
    guard let data = fileManager.contents(atPath: fileURL.path) else {
      throw CacheStorageError.noDataSaved
    }
    
    let cacheItem = try JSONDecoder().decode(CacheItem<T>.self, from: data)
    
    guard cacheItem.expires > Date() else {
      try? invalidateCache(cacheInfo: cacheInfo)
      throw CacheStorageError.cacheExpired
    }
    
    return cacheItem.object
  }
  
  func invalidateCache(cacheInfo: CacheInfo) throws {
    let fileURL = try makeFileURL(fileName: cacheInfo.key, group: cacheInfo.itemGroup)
    if fileManager.fileExists(atPath: fileURL.path) {
      try fileManager.removeItem(at: fileURL)
    }
  }
  
  func invalidateGroup(group: String) throws {
    let groupURL = try directoryURL().appendingPathComponent(group, isDirectory: true)
    if fileManager.fileExists(atPath: groupURL.path) {
      try fileManager.removeItem(at: groupURL)
    }
  }
  
  func clearAllData() throws {
    let folderURL = try directoryURL()
    let contents = try fileManager.contentsOfDirectory(atPath: folderURL.path)
    for filePath in contents {
      let fullFileURL = folderURL.appendingPathComponent(filePath, isDirectory: true)
      try fileManager.removeItem(at: fullFileURL)
    }
  }
  
  private func makeFileURL(fileName: String, group: String) throws -> URL {
    var directory = try directoryURL().appendingPathComponent(group, isDirectory: true)
    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    var resourceValues = URLResourceValues()
    resourceValues.isExcludedFromBackup = true
    try directory.setResourceValues(resourceValues)
    
    return directory.appendingPathComponent(fileName, isDirectory: false)
  }
  
  private func directoryURL() throws -> URL {
    var directoryURL = try fileManager.url(for: .documentDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: true).appendingPathComponent(folderName, isDirectory: true)
    try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    var resourceValues = URLResourceValues()
    resourceValues.isExcludedFromBackup = true
    try directoryURL.setResourceValues(resourceValues)
    return directoryURL
  }
}
