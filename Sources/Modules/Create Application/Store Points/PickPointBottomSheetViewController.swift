//
//  PickPointBottomSheetViewController.swift
//  ForwardLeasing
//

import UIKit

class PickPointBottomSheetViewController: BaseBottomSheetViewController {
  // MARK: - Subviews
  private let pickupPlaceView = PickupPlaceView()
  
  // MARK: - Properties
  override var skipPointVerticalVelocity: CGFloat {
    return view.bounds.height / 2
  }
  
  private let viewModel: PickPointBottomSheetViewModel
  
  // MARK: - Init
  init(viewModel: PickPointBottomSheetViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  // MARK: - Private
  private func setup() {
    pickupPlaceView.configure(with: viewModel.pickupPlaceViewModel)
    view.addSubview(pickupPlaceView)
    pickupPlaceView.onNeedsToPresentViewController = { [weak self] viewController in
      self?.present(viewController, animated: true, completion: nil)
    }
    pickupPlaceView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func bind() {
    viewModel.onDidUpdate = { [weak self] in
      guard let self = self else { return }
      self.pickupPlaceView.configure(with: self.viewModel.pickupPlaceViewModel)
      self.shouldResize = true
      self.forceLayout()
    }
  }
}
