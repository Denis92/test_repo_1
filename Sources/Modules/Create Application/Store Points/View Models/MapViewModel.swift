//
//  MapViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit
import YandexMapsMobile

private extension Constants {
  static let applePhone = "Apple"
  static let appleCategory = "PHONES_APPLE"
  static let otherCategory = "PHONES"
}

protocol MapViewModelDelegate: class {
  func mapViewModel(_ viewModel: MapViewModel, didRequestShowPointWithInfo pointInfo: StorePointInfo)
  func mapViewModelDidRequestClose(_ viewModel: MapViewModel)
}

struct MapViewModelInput {
  let leasingEntity: LeasingEntity
  let storePoint: StorePointInfo?
}

class MapViewModel: NSObject {
  // MARK: - Types
  typealias Dependencies = HasDeliveryService & HasMapService
  
  // MARK: - Properties
  var onDidReceiveError: ((Error) -> Void)?
  var onDidCopy: (() -> Void)?
  var onRequestCreateUserLocationLayer: (() -> Void)?
  var onDidUpdateInterface: (() -> Void)?
  
  weak var delegate: MapViewModelDelegate?
  
  var map: YMKMap?
  
  private(set) var isHiddenInterface: Bool = false {
    didSet {
      if oldValue != isHiddenInterface {
        onDidUpdateInterface?()
      }
    }
  }
  
  private var mapObjects: YMKMapObjectCollection? {
    return map?.mapObjects
  }
  private var userLocation: YMKLocation? {
    didSet {
      guard userLocation != nil && !isInitialySetUserLocation else { return }
      setupUserLocationOrSelectedPickPoint()
      isInitialySetUserLocation = true
    }
  }

  private var pointAvailabilityUtil = PointAvailabilityUtil()
  private var mapObjectsCollection: YMKMapObjectCollection?
  private let dependencies: Dependencies
  private var hasUserLayer: Bool = false
  private var selectedMapObject: YMKMapObject?
  private var isInitialySetUserLocation: Bool = false
  private let input: MapViewModelInput
  private var pointsGoods: [String: Set<String>] = [:]
  
  // MARK: - Init
  
  init(dependencies: Dependencies,
       input: MapViewModelInput) {
    self.dependencies = dependencies
    self.input = input
    super.init()
    dependencies.mapService.delegate = self
  }

  deinit {
    mapObjectsCollection?.clear()
    mapObjects?.removeTapListener(with: self)
  }
  
  // MARK: - Public Methods
  
  func load() {
    setupUserLocationOrSelectedPickPoint()
    firstly {
      dependencies.deliveryService.getStores(categoryCode: getCategoryCode(),
                                             goodCode: input.leasingEntity.productInfo.goodCode)
    }.then { response in
      self.pointAvailabilityUtil.calculateAvailability(goodCode: self.input.leasingEntity.productInfo.goodCode,
                                                       for: response.points)
    }.done { points in
      self.handle(points: points)
    }.catch { error in
      self.onDidReceiveError?(error)
    }
  }
  
  // MARK: - Actions
  func zoomIn() {
    updateZoom(offset: 1)
  }
  
  func zoomOut() {
    updateZoom(offset: -1)
  }
  
  func updateMap(isHiddenInterface: Bool) {
    self.isHiddenInterface = isHiddenInterface
  }
  
  func setupUserLocationOrSelectedPickPoint() {
    guard let map = map else { return }
    let target: YMKPoint
    var cameraCallback: YMKMapCameraCallback?
    if let initialStorePoint = input.storePoint {
      target = YMKPoint(latitude: initialStorePoint.latitude, longitude: initialStorePoint.longitude)
      guard let collection = mapObjects?.add() else { return }
      addInitialMapObject(to: collection, cameraCallback: &cameraCallback)
    } else {
      target = userLocation?.position ?? YMKPoint(latitude: 0, longitude: 0)
    }
    let position = YMKCameraPosition(target: target, zoom: 14,
                                     azimuth: 0, tilt: 0)
    map.move(with: position,
             animationType: YMKAnimation(type: .smooth, duration: 0.4),
             cameraCallback: cameraCallback)
    guard !hasUserLayer else { return }
    onRequestCreateUserLocationLayer?()
    hasUserLayer = true
  }
  
  func close() {
    delegate?.mapViewModelDidRequestClose(self)
  }
  
  func resetSelectedMapObject() {
    if let selectedPlacemark = selectedMapObject as? YMKPlacemarkMapObject,
       let isEnabled = (selectedPlacemark.userData as? StorePointViewModel)?.isEnabled,
       let icon = PinAsset(isEnabled: isEnabled, isSelected: false).icon {
      selectedPlacemark.setIconWith(icon)
    }
  }
  
  // MARK: - Private Methods
  private func getCategoryCode() -> String {
    guard let goodName = input.leasingEntity.productInfo.goodName else { return Constants.otherCategory }
    return goodName.lowercased().contains(Constants.applePhone.lowercased()) ? Constants.appleCategory : Constants.otherCategory
  }
  
  private func addInitialMapObject(to collection: YMKMapObjectCollection,
                                   cameraCallback: inout YMKMapCameraCallback?) {
    guard let initialPoint = input.storePoint else { return }
    let mapObject = addPlacemark(for: initialPoint, isSelected: true, to: collection)
    mapObject.addTapListener(with: self)
    selectedMapObject = mapObject
    delegate?.mapViewModel(self, didRequestShowPointWithInfo: initialPoint)
    cameraCallback = { [weak mapObject] _ in
      let icon = PinAsset(isEnabled: initialPoint.hasRequiredGood, isSelected: true).icon ?? UIImage()
      mapObject?.setIconWith(icon)
    }
  }
  
  private func updateZoom(offset: Float) {
    guard let map = map else { return }
    let position = YMKCameraPosition(target: map.cameraPosition.target,
                                     zoom: map.cameraPosition.zoom + offset,
                                     azimuth: 0, tilt: 0)
    map.move(with: position,
             animationType: YMKAnimation(type: .smooth, duration: 0.4))
  }

  private func handle(points: [StorePointInfo]) {
    mapObjectsCollection?.clear()
    mapObjects?.removeTapListener(with: self)
    guard let collection = mapObjects?.add() else { return }
    self.mapObjectsCollection = collection
    collection.addTapListener(with: self)
    for point in points {
      guard point != input.storePoint else { continue }
      addPlacemark(for: point, isSelected: false, to: collection)
    }
  }
  
  @discardableResult
  private func addPlacemark(for point: StorePointInfo,
                            isSelected: Bool,
                            to collection: YMKMapObjectCollection) -> YMKPlacemarkMapObject {
    let mapPoint = YMKPoint(latitude: point.latitude, longitude: point.longitude)
    let mapObject = collection.addPlacemark(with: mapPoint,
                                            image: PinAsset(isEnabled: point.hasRequiredGood,
                                                            isSelected: isSelected).icon ?? UIImage(),
                                            style: YMKIconStyle())
    let pointViewModel = StorePointViewModel(isEnabled: point.hasRequiredGood) { [weak self, point] in
      guard let self = self else { return }
      self.delegate?.mapViewModel(self, didRequestShowPointWithInfo: point)
    }
    mapObject.userData = pointViewModel
    return mapObject
  }
  
  private func copy(text: String) {
    UIPasteboard.general.string = text
    onDidCopy?()
  }
}

// MARK: - YMKMapObjectTapListener
extension MapViewModel: YMKMapObjectTapListener {
  func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    guard let pointViewModel = mapObject.userData as? StorePointViewModel else {
      return false
    }
    resetSelectedMapObject()
    selectedMapObject = mapObject
    if let placemark = mapObject as? YMKPlacemarkMapObject, let icon = PinAsset(isEnabled: pointViewModel.isEnabled,
                                                                                isSelected: true).icon {
      placemark.setIconWith(icon)
    }
    pointViewModel.onDidSelect?()
    return true
  }
}

// MARK: - MapServiceDelegate
extension MapViewModel: MapServiceDelegate {
  func mapService(_ service: MapService,
                  didUpdateUserLocation userLocation: YMKLocation) {
    self.userLocation = userLocation
  }
}
