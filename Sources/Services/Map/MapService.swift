//
//  MapService.swift
//  ForwardLeasing
//

private extension Constants {
  static let key = "16d10970-51e4-480c-a463-9bb576b88101"
}

import Foundation
import YandexMapsMobile

protocol MapServiceDelegate: class {
  func mapService(_ service: MapService, didUpdateUserLocation userLocation: YMKLocation)
  func mapService(_ service: MapService, didUpdateLocationStatus status: YMKLocationStatus)
}

extension MapServiceDelegate {
  func mapService(_ service: MapService, didUpdateLocationStatus status: YMKLocationStatus) {}
}

class MapService: NSObject {
  // MARK: - Properties
  weak var delegate: MapServiceDelegate? {
    didSet {
      locationManager.unsubscribe(withLocationListener: self)
      guard delegate != nil else {
        return
      }
      locationManager.requestSingleUpdate(withLocationListener: self)
    }
  }
  private lazy var locationManager = YMKMapKit.sharedInstance().createLocationManager()
  
  // MARK: - Public
  func initialize() {
    YMKMapKit.setApiKey(Constants.key)
  }
}

// MARK: - YMKLocationDelegate
extension MapService: YMKLocationDelegate {
  func onLocationUpdated(with location: YMKLocation) {
    delegate?.mapService(self, didUpdateUserLocation: location)
  }
  
  func onLocationStatusUpdated(with status: YMKLocationStatus) {
    delegate?.mapService(self, didUpdateLocationStatus: status)
  }
}
