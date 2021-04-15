//
//  CollectionViewDataSource.swift
//  ForwardLeasing
//

import UIKit

protocol CollectionViewDataSourceDelegate: class {
  func collectionViewDataSourceDidScroll(_ dataSource: CollectionViewDataSource, scrollView: UIScrollView)
}

class CollectionViewDataSource: NSObject, CollectionViewDataSourceProtocol {
  let lineSpacing: CGFloat
  let interItemSpacing: CGFloat
  let itemSize: CGSize

  private (set) var items: [CommonCollectionCellViewModel] = []
  private var footerViewModel: CommonCollectionHeaderFooterViewModel?
  private var headerViewModel: CommonCollectionHeaderFooterViewModel?

  weak var delegate: CollectionViewDataSourceDelegate?

  init(lineSpacing: CGFloat, interItemSpacing: CGFloat, itemSize: CGSize) {
    self.lineSpacing = lineSpacing
    self.interItemSpacing = interItemSpacing
    self.itemSize = itemSize
  }

  func setup(collectionView: UICollectionView,
             viewModel: CommonCollectionViewModel) {
    collectionView.dataSource = self
    collectionView.delegate = self
    items = viewModel.collectionCellViewModels
  }

  func setup(collectionView: UICollectionView,
             collectionViewLayout: UICollectionViewFlowLayout,
             viewModel: CommonCollectionViewModel) {
    setup(collectionView: collectionView, viewModel: viewModel)
    collectionViewLayout.minimumLineSpacing = lineSpacing
    collectionViewLayout.minimumInteritemSpacing = interItemSpacing
  }

  func setup(collectionView: UICollectionView,
             collectionViewLayout: UICollectionViewFlowLayout,
             viewModel: CommonCollectionViewModel,
             headerViewModel: CommonCollectionHeaderFooterViewModel? = nil,
             footerViewModel: CommonCollectionHeaderFooterViewModel? = nil) {
    self.footerViewModel = footerViewModel
    self.headerViewModel = headerViewModel
    setup(collectionView: collectionView, viewModel: viewModel)
    collectionViewLayout.minimumLineSpacing = lineSpacing
    collectionViewLayout.minimumInteritemSpacing = interItemSpacing
  }

  func update(viewModel: CommonCollectionViewModel) {
    items = viewModel.collectionCellViewModels
  }
}

// MARK: - Default UICollectionViewDataSource methods

extension CollectionViewDataSource: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return numberOfSections
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfItems(in: section)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let itemViewModel = items.element(at: indexPath.item),
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemViewModel.collectionCellIdentifier,
                                                    for: indexPath) as? UICollectionViewCell & CommonCollectionCell else {
                                                      return UICollectionViewCell()
    }
    cell.configure(with: itemViewModel)
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath) -> UICollectionReusableView {
    var view: UICollectionReusableView?
    if kind == UICollectionView.elementKindSectionFooter, let identifier = footerViewModel?.viewIdentifier {
      view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                             withReuseIdentifier: identifier, for: indexPath)
      if let view = view as? CommonConfigurableHeaderFooterView, let footerViewModel = footerViewModel {
        view.configure(with: footerViewModel)
        return view as? UICollectionReusableView ?? UICollectionReusableView()
      }
    }
    if kind == UICollectionView.elementKindSectionHeader, let identifier = headerViewModel?.viewIdentifier {
      view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                             withReuseIdentifier: identifier, for: indexPath)
      if let view = view as? CommonConfigurableHeaderFooterView, let headerViewModel = headerViewModel {
        view.configure(with: headerViewModel)
        return view as? UICollectionReusableView ?? UICollectionReusableView()
      }
    }

    return UICollectionReusableView()
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForFooterInSection section: Int) -> CGSize {
    return footerViewModel?.viewSize ?? .zero
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
    return headerViewModel?.viewSize ?? .zero
  }
}

// MARK: - Default UICollectionViewDelegateFlowLayout methods

extension CollectionViewDataSource: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return itemSize
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return lineSpacing
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return interItemSpacing
  }
}

// MARK: - Default UICollectionViewDelegate methods

extension CollectionViewDataSource: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if let cell = collectionView.cellForItem(at: indexPath) as? CommonCollectionCell {
      cell.setSelected(true)
    }
    return true
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let itemViewModel = items.element(at: indexPath.item) else { return }
    itemViewModel.selectCollectionCell()
  }

  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) as? CommonCollectionCell {
      cell.setSelected(false)
    }
  }

  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) as? CommonCollectionCell {
      cell.setHighlighted(true)
    }
  }

  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) as? CommonCollectionCell {
      cell.setHighlighted(false)
    }
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    delegate?.collectionViewDataSourceDidScroll(self, scrollView: scrollView)
  }
}
