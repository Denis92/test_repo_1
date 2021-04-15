//
//  StorePointsCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol StorePointsCoordinatorDelegate: AnyObject {
  func storePointsCoordinatorDidRequestClose(_ coordinator: StorePointsCoordinator)
  func storePointsCoordinator(_ coordinator: StorePointsCoordinator,
                              didFinishWithSelectedStorePoint storePoint: StorePointInfo)
}

struct StorePointsCoordinatorConfiguration {
  let leasingEntity: LeasingEntity
  let storePoint: StorePointInfo?
}

class StorePointsCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = StorePointsCoordinatorConfiguration
  // MARK: - Properties
  
  weak var delegate: StorePointsCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  private let configuration: Configuration
  
  private var onDidHidePickpoint: (() -> Void)?
  private var onDidShowPickpoint: (() -> Void)?
  private var onDidUpdateStorePoint: ((StorePointInfo) -> Void)?
  private var onDidRequestHidePickPoint: (() -> Void)?
  private var onDidRequestUnselectPin: (() -> Void)?
  
  private var isHiddenBottomSheet = true
  
  // MARK: - Init
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.configuration = configuration
  }
  
  // MARK: - Public Methods
  
  func start(animated: Bool) {
    showMap()
  }
  
  // MARK: - Private Methods
  private func showMap() {
    let input = MapViewModelInput(leasingEntity: configuration.leasingEntity,
                                  storePoint: configuration.storePoint)
    let viewModel = MapViewModel(dependencies: appDependency,
                                 input: input)
    onDidHidePickpoint = { [weak viewModel] in
      viewModel?.updateMap(isHiddenInterface: false)
    }
    onDidShowPickpoint = { [weak viewModel] in
      viewModel?.updateMap(isHiddenInterface: true)
    }
    onDidRequestUnselectPin = { [weak viewModel] in
      viewModel?.resetSelectedMapObject()
    }
    viewModel.delegate = self
    let controller = MapViewController(viewModel: viewModel)
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func showPickpointInformation(with point: StorePointInfo) {
    guard isHiddenBottomSheet else {
      onDidUpdateStorePoint?(point)
      return
    }
    let pickupButtonTitleStrategy: PickupButtonTitleStrategy = configuration.leasingEntity.status == .returnCreated
      ? ReturnPickupButtonTitleStrategy()
      : ExchangePickupButtonTitleStrategy()
    let viewModel = PickPointBottomSheetViewModel(storePoint: point,
                                                  pickupButtonTitleStrategy: pickupButtonTitleStrategy)
    viewModel.delegate = self
    onDidUpdateStorePoint = { [weak viewModel] point in
      viewModel?.update(point: point)
    }
    let viewController = PickPointBottomSheetViewController(viewModel: viewModel)
    onDidRequestHidePickPoint = { [weak viewController] in
      viewController?.removeBottomSheetViewController(animated: true)
    }
    viewController.onDidRemoveBottomSheetViewController = { [weak self] in
      self?.onDidHidePickpoint?()
      self?.isHiddenBottomSheet = true
      self?.onDidRequestUnselectPin?()
    }
    navigationController.topViewController?
      .addBottomSheetViewController(withDarkView: false,
                                    viewController: viewController, animated: true,
                                    shouldResize: true)
    isHiddenBottomSheet = false
  }
}

// MARK: - MapViewModelDelegate
extension StorePointsCoordinator: MapViewModelDelegate {
  func mapViewModel(_ viewModel: MapViewModel, didRequestShowPointWithInfo pointInfo: StorePointInfo) {
    showPickpointInformation(with: pointInfo)
    onDidShowPickpoint?()
  }
  
  func mapViewModelDidRequestClose(_ viewModel: MapViewModel) {
    delegate?.storePointsCoordinatorDidRequestClose(self)
  }
}

// MARK: - PickPointBottomSheetViewModelDelegate
extension StorePointsCoordinator: PickPointBottomSheetViewModelDelegate {  
  func pickPointBottomSheetViewModel(_ viewModel: PickPointBottomSheetViewModel,
                                     didSelectPoint point: StorePointInfo) {
    delegate?.storePointsCoordinator(self, didFinishWithSelectedStorePoint: point)
  }
  
  func pickPointBottomSheetViewModelDidRequestClose(_ viewModel: PickPointBottomSheetViewModel) {
    onDidRequestHidePickPoint?()
  }
}
