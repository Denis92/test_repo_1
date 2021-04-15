//
//  CurrentApplicationsTableHeaderViewModel.swift
//  ForwardLeasing
//

import Foundation

struct CurrentApplicationsTableHeaderViewModel: CommonTableHeaderFooterViewModel {
  var headerFooterReuseIdentifier: String {
    return CommonContainerHeaderFooterView<CurrentApplicationsTableHeaderView>.reuseIdentifier
  }
  
  var descriptionText: String {
    return isUpgrade
      ? R.string.currentApplications.screenDescriptionUpgrade()
      : R.string.currentApplications.screenDescriptionNew()
  }

  private let isUpgrade: Bool

  init(isUpgrade: Bool) {
    self.isUpgrade = isUpgrade
  }
}
