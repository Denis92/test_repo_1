//
//  SegmentedControlView.swift
//  ForwardLeasing
//

import UIKit

protocol SegmentedControlViewModelProtocol: class {
  var segmentsTitles: [String] { get }
  var selectedSegmentIndex: Int { get }

  func selectSegment(at index: Int)
}

class SegmentedControlView: UIView, Configurable {
  // MARK: - Properties
  private var onDidSelectSegment: ((Int) -> Void)?
  private let segmentedControl = SegmentedControl()

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
  func configure(with viewModel: SegmentedControlViewModelProtocol) {
    segmentedControl.setTabs(titles: viewModel.segmentsTitles)
    segmentedControl.setSelectedIndex(viewModel.selectedSegmentIndex, animated: false) 
    onDidSelectSegment = { [weak viewModel] index in
      viewModel?.selectSegment(at: index)
    }
    segmentedControl.setNeedsLayout()
    segmentedControl.layoutIfNeeded()
  }

  // MARK: - Private methods
  private func setup() {
    addSegmentedControl()
  }

  private func addSegmentedControl() {
    addSubview(segmentedControl)
    segmentedControl.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.bottom.equalToSuperview().inset(8)
    }
    segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
  }

  // MARK: - Actions
  @objc private func segmentChanged() {
    onDidSelectSegment?(segmentedControl.selectedIndex)
  }
}
