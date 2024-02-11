import UIKit
import Combine
import SnapKit

class NoteViewController: UIViewController {
    private lazy var verticalStack = initializeVerticalStack()
    private lazy var tagButton = initializeTagButton()
    private lazy var descriptionText = initializeDescriptionText()

    private var keyboardHeight: CGFloat = 0

    private var textChanged = false
    private var tagChanged = false

    private var subscriptions = Set<AnyCancellable>()

    private var viewModel: NoteViewModel?
}

// MARK: - Life cycle

extension NoteViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureNavigationItem()

        addSubviews()

        updateApplyButtonItemEnabled()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeOnNotificationCenter()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSubviewsContraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotificationCenter()
    }
}

// MARK: - Initializators

extension NoteViewController {
    func initialize(viewModel: NoteViewModel) {
        self.viewModel = viewModel

        viewModel.$tag.sink { [weak self] tag in
            if self?.viewModel?.tag.id != tag.id {
                self?.tagChanged = true
                self?.updateApplyButtonItemEnabled()
            }

            let tagName = tag.name.capitalized
            self?.tagButton.setTitle(tagName, for: .normal)

            DispatchQueue.main.async {
                self?.initializeTagItems()
            }
        }.store(in: &subscriptions)

        descriptionText.text = viewModel.note.text

        DispatchQueue.main.async { [weak self] in
            self?.viewModel?.fetch()
            DispatchQueue.main.async {
                self?.initializeTagItems()
            }
        }
    }

    private func initializeTagItems() {
        guard let tags = viewModel?.tags, tags.count > 1 else {
            return
        }

        let actions = tags.map { [weak self] tag in
            let title = tag.name.capitalized
            let currentTag = self?.viewModel?.tag
            let state = currentTag?.id == tag.id ? UIMenuElement.State.on : .off
            let action = UIAction(title: title, state: state) { [tag] _ in
                self?.viewModel?.tag = tag
            }
            return action
        }
        let menu = UIMenu(children: actions)

        tagButton.menu = menu
    }

    private func initializeDescriptionTextToolbar() -> UIToolbar {
        let flexibleButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                             target: self,
                                             action: #selector(onDoneButtonItemTapped))
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [flexibleButtonItem, doneButtonItem]
        return toolbar
    }
}

// MARK: - Configurators

extension NoteViewController {
    private func configureView() {
        view.backgroundColor = .systemBackground
    }

    func configureNavigationItem() {
        let applyButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(onApplyButtonItemTapped))
        navigationItem.rightBarButtonItem = applyButtonItem
    }
}

// MARK: - Subscriptions

extension NoteViewController {
    private func subscribeOnNotificationCenter() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(onKeyboardWillShow),
                           name: UIResponder.keyboardWillShowNotification,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(onKeyboardWillHide),
                           name: UIResponder.keyboardWillHideNotification,
                           object: nil)
    }

    private func unsubscribeFromNotificationCenter() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Subviews

extension NoteViewController {
    private func initializeVerticalStack() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 10
        return view
    }

    private func initializeTagButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 10
        button.showsMenuAsPrimaryAction = true
        return button
    }

    private func initializeDescriptionText() -> UITextView {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.font = .boldSystemFont(ofSize: 20)
        view.textColor = .systemGray
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        view.inputAccessoryView = initializeDescriptionTextToolbar()
        return view
    }

    private func addSubviews() {
        view.addSubview(verticalStack)
        verticalStack.addArrangedSubview(tagButton)
        verticalStack.addArrangedSubview(descriptionText)
    }

    private func updateSubviewsContraints() {
        verticalStack.snp.updateConstraints { maker in
            maker.left.right.equalToSuperview().inset(16)
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)

            var bottomInset: CGFloat
            if keyboardHeight > 0 {
                bottomInset = keyboardHeight - view.safeAreaInsets.bottom + CGFloat(16)
            } else {
                bottomInset = 16
            }
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(bottomInset)
        }
        tagButton.snp.updateConstraints { maker in
            maker.height.equalTo(50)
        }
    }
}

// MARK: - Bar button item

extension NoteViewController {
    private func updateApplyButtonItemEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = !descriptionText.text.isEmpty && (tagChanged || textChanged)
    }
}

// MARK: - UITextViewDelegate

extension NoteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textChanged = true
        updateApplyButtonItemEnabled()
    }
}

// MARK: - Callbacks

extension NoteViewController {
    @objc private func onKeyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        keyboardHeight = keyboardFrame.height

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    @objc private func onKeyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    @objc private func onApplyButtonItemTapped() {
        viewModel?.updateNote(text: descriptionText.text)
        viewModel?.applyNote()
        navigationController?.popViewController(animated: true)
    }

    @objc private func onDoneButtonItemTapped() {
        descriptionText.resignFirstResponder()
    }
}
