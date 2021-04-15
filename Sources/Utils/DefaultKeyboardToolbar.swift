//
//  DefaultKeyboardToolbar.swift
//  ForwardLeasingTests
//

import UIKit

class DefaultKeyboardToolbar: UIToolbar {
  // MARK: - Callbacks

  var onDidTapPrev: (() -> Void)?
  var onDidTapNext: (() -> Void)?
  var onDidTapDone: (() -> Void)?

  // MARK: - Subviews

  private let previuosButton: UIBarButtonItem = {
    let barButtonItem = UIBarButtonItem()
    barButtonItem.image = R.image.toolbarBackIcon()
    barButtonItem.tintColor = .base1
    return barButtonItem
  }()

  private let nextButton: UIBarButtonItem = {
    guard let backIcon = R.image.toolbarBackIcon(), let cgBackImage = backIcon.cgImage else {
      return UIBarButtonItem()
    }
    let barButtonItem = UIBarButtonItem()
    let flippedImage = UIImage(cgImage: cgBackImage, scale: backIcon.scale, orientation: .upMirrored)
    barButtonItem.image = flippedImage.withRenderingMode(.alwaysTemplate)
    barButtonItem.tintColor = .base1
    return barButtonItem
  }()

  private var doneButton: UIBarButtonItem = {
    let button = UIButton(type: .system)
    button.setTitle(R.string.common.done(), for: .normal)
    button.setTitleColor(.base1, for: .normal)
    button.titleLabel?.font = .textRegular
    button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
    return UIBarButtonItem(customView: button)
  }()

  private let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                    target: nil, action: nil)

  // MARK: - Public

  var hasPreviousItem: Bool {
    get { return previuosButton.isEnabled }
    set { previuosButton.isEnabled = newValue }
  }

  var hasNextItem: Bool {
    get { return nextButton.isEnabled }
    set { nextButton.isEnabled = newValue }
  }

  func setDoneButtonEnabled(_ isEnabled: Bool) {
    doneButton.isEnabled = isEnabled
  }

  // MARK: - Init

  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  private func setup() {
    backgroundColor = .white

    previuosButton.target = self
    previuosButton.action = #selector(didTapPrevious)
    nextButton.target = self
    nextButton.action = #selector(didTapNext)

    let items = [previuosButton, nextButton, flexibleSpaceButton, doneButton]
    setItems(items, animated: false)

    snp.makeConstraints { make in
      make.height.equalTo(44)
    }
  }

  // MARK: - Actions

  @objc private func didTapPrevious() {
    onDidTapPrev?()
  }

  @objc private func didTapNext() {
    onDidTapNext?()
  }

  @objc private func didTapDone() {
    onDidTapDone?()
  }
}
