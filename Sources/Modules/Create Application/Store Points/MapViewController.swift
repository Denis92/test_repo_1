//
//  MapViewController.swift
//  ForwardLeasing
//

import UIKit
import YandexMapsMobile

private extension Constants {
  static let userLocationIcon = "userLocation"
}

class MapViewController: BaseViewController, NavigationBarHiding {
  // MARK: - Outlets
  private let mapView = YMKMapView()
  private var isHiddenBottomSheet = true {
    didSet {
      if isHiddenBottomSheet {
        bottomSheet = nil
      }
    }
  }
  private let buttonsContainer = UIStackView()
  private let closeButton = UIButton(type: .system)
  private var bottomSheet: BottomSheetViewController?
  
  // MARK: - Properties
  private let viewModel: MapViewModel
  
  // MARK: - Init
  
  init(viewModel: MapViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    viewModel.map = mapView.mapWindow.map
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
    viewModel.load()
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupMapView()
    setupCloseButton()
    setupButtonsContainer()
  }
  
  private func setupMapView() {
    view.addSubview(mapView)
    mapView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupCloseButton() {
    view.addSubview(closeButton)
    closeButton.setImage(R.image.darkCloseIcon(), for: .normal)
    closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    closeButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalToSuperview().inset(68)
    }
  }
  
  private func setupButtonsContainer() {
    view.addSubview(buttonsContainer)
    buttonsContainer.axis = .vertical
    buttonsContainer.spacing = 24
    buttonsContainer.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(20)
    }
    buttonsContainer.isHidden = viewModel.isHiddenInterface
    
    let zoomInButton = UIButton(type: .system)
    zoomInButton.setImage(R.image.zoomIn(), for: .normal)
    zoomInButton.alpha = 0.8
    zoomInButton.addTarget(self, action: #selector(didTapZoomIn), for: .touchUpInside)
    buttonsContainer.addArrangedSubview(zoomInButton)
    
    let zoomOutButton = UIButton(type: .system)
    zoomOutButton.setImage(R.image.zoomOut(), for: .normal)
    zoomOutButton.alpha = 0.8
    zoomOutButton.addTarget(self, action: #selector(didTapZoomOut), for: .touchUpInside)
    buttonsContainer.addArrangedSubview(zoomOutButton)
    
    let userLocationButton = UIButton(type: .system)
    userLocationButton.setImage(R.image.userLocation(), for: .normal)
    userLocationButton.alpha = 0.8
    userLocationButton.addTarget(self, action: #selector(didTapUserLocation), for: .touchUpInside)
    buttonsContainer.addArrangedSubview(userLocationButton)
  }
  
  private func bind() {
    viewModel.onDidReceiveError = { [weak self] error in
      self?.handle(error: error)
    }
    viewModel.onDidCopy = { [weak self] in
      self?.showBanner(text: R.string.map.addressCopied())
    }
    viewModel.onRequestCreateUserLocationLayer = { [weak self] in
      self?.createUserLocationLayer()
    }
    viewModel.onDidUpdateInterface = { [weak self] in
      guard let self = self else { return }
      self.buttonsContainer.isHidden = self.viewModel.isHiddenInterface
    }
  }
  
  private func createUserLocationLayer() {
    let mapKit = YMKMapKit.sharedInstance()
    let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)

    userLocationLayer.setVisibleWithOn(true)
    userLocationLayer.isHeadingEnabled = true
    userLocationLayer.setObjectListenerWith(self)
  }
  
  // MARK: - Actions
  @objc private func didTapClose() {
    viewModel.close()
  }
  
  @objc private func didTapZoomIn() {
    viewModel.zoomIn()
  }
  
  @objc private func didTapZoomOut() {
    viewModel.zoomOut()
  }
  
  @objc private func didTapUserLocation() {
    viewModel.setupUserLocationOrSelectedPickPoint()
  }
}

// MARK: - YMKUserLocationObjectListener
extension MapViewController: YMKUserLocationObjectListener {
  func onObjectAdded(with view: YMKUserLocationView) {
    let pinPlacemark = view.pin.useCompositeIcon()
    if let icon = R.image.pinUserLocation() {
      pinPlacemark.setIconWithName(Constants.userLocationIcon, image: icon, style: YMKIconStyle())
    }
  }
  
  func onObjectRemoved(with view: YMKUserLocationView) {}
  
  func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}
}
