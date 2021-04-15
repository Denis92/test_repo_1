//
//  SegmentedControlViewModel.swift
//  ForwardLeasing
//

import Foundation

class ProfileSegmentedControlCellModel: SegmentedControlViewModelProtocol, CommonTableCellViewModel {
  // MARK: - Properties
  var segmentsTitles: [String]
  private(set) var selectedSegmentIndex: Int = 0

  var tableCellIdentifier: String {
    return ProfileSegmentedControlCell.reuseIdentifier
  }

  weak var delegate: ProfileCellViewModelsDelegate?

  // MARK: - Init
  init() {
    self.segmentsTitles = ProfileSegment.allCases.map { $0.description }
  }

  // MARK: - Methods
  func selectSegment(at index: Int) {
    guard selectedSegmentIndex != index, let segment = ProfileSegment(rawValue: index) else {
      return
    }
    selectedSegmentIndex = index
    delegate?.cellViewModel(self, didSelect: .selectSegment(segment))
  }
}
