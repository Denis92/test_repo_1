//
//  PaymentCardPickerView.swift
//  ForwardLeasing
//

import UIKit

class PaymentCardPickerView: NibView, Configurable {
  typealias ViewModel = PaymentCardPickerViewModel
  // MARK: - Outlets

  @IBOutlet private weak var selectedCardLabel: AttributedLabel! {
    didSet {
      selectedCardLabel.change(textStyle: .bodyBold)
    }
  }
  @IBOutlet private weak var saveCardDataLabel: AttributedLabel! {
    didSet {
      saveCardDataLabel.change(textStyle: .bodyBold)
      saveCardDataLabel.text = R.string.paymentRegistration.saveCardData()
    }
  }
  @IBOutlet private weak var cardListOpeningIndicatorImageView: UIImageView!
  @IBOutlet private weak var saveNewCardDataIndicatorImageView: UIImageView!
  @IBOutlet private weak var cardsStackView: UIStackView!
  @IBOutlet private weak var saveNewCardContainerView: UIView!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private weak var cardsContainerView: UIStackView!
  @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var showAllCardsButton: UIButton!

  // MARK: - Peoperties
  private var viewModel: PaymentCardPickerViewModel?

  // MARK: - Public methods

  func prepareForReuse() {
    viewModel = nil
  }

  func configure(with viewModel: PaymentCardPickerViewModel) {
    self.viewModel = viewModel
    viewModel.onDidChangeSelectedCard = { [weak self] in
      self?.updateSelectedCard()
    }
    viewModel.onDidUpdateCards = { [weak self] in
      self?.updateCards()
    }
    viewModel.onDidStartRequest = { [weak self] in
      self?.saveNewCardContainerView.isHidden = true
      self?.showAllCardsButton.isEnabled = false
      self?.activityIndicatorView.startAnimating()
    }
    viewModel.onDidFinishRequest = { [weak self, weak viewModel] in
      guard let viewModel = viewModel else { return }
      self?.saveNewCardContainerView.isHidden = !viewModel.newCardConfigurationVisible
      self?.showAllCardsButton.isEnabled = true
      self?.activityIndicatorView.stopAnimating()
    }
    updateCards()
    updateSelectedCard()
  }

  // MARK: - Actions

  @IBAction private func saveNewCardDataButtonTapped(_ sender: Any) {
    viewModel?.toggleCardDataSavingState()
  }

  @IBAction private func showCardsButtonTapped(_ sender: Any) {
    cardsStackView.isHidden.toggle()
    separatorView.isHidden = cardsStackView.isHidden
    let icon = cardsStackView.isHidden ? R.image.dropDownIcon() : R.image.dropDownActivceIcon()
    cardListOpeningIndicatorImageView.image = icon
  }

  // MARK: - Private methods

  private func updateSelectedCard() {
    guard let viewModel = viewModel else { return }
    selectedCardLabel.text = viewModel.selectedCardTitle
    saveNewCardContainerView.isHidden = !viewModel.newCardConfigurationVisible
    let icon = viewModel.shouldSaveNewCardData ? R.image.checkboxSquareOn() : R.image.checkboxRoundOff()
    saveNewCardDataIndicatorImageView.image = icon
  }

  private func updateCards() {
    guard let viewModel = viewModel else { return }
    cardsStackView.arrangedSubviews.forEach {
      cardsStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    viewModel.cardViewModels.enumerated().forEach { offset, element in
      let buttonView = ButtonView()
      buttonView.onDidTap = { [weak viewModel] in
        viewModel?.selectCard(at: offset)
      }
      buttonView.configure(with: makeCardView(with: element))
      cardsStackView.addArrangedSubview(buttonView)
    }
  }

  private func makeCardView(with viewModel: PaymentCardViewModel) -> PaymentCardView {
    let view = PaymentCardView()
    view.configure(with: viewModel)
    return view
  }
}
