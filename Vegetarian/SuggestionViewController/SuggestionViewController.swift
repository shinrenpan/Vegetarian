//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import Combine
import UIKit

final class SuggestionViewController: UIViewController {

    let _viewModel = SuggestionViewModel()
    let _viewOutlet = SuggestionViewOutlet.FromXib()
    private var _bindings = Set<AnyCancellable>()
}

// MARK: - ViewController Life Cycle

extension SuggestionViewController {

    override func loadView() {
        view = _viewOutlet.mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidChangeFrameNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] sender in
            self?._viewOutlet.reloadUIWhenKeyboardDidChangeFrame(sender)
        }

        __commonInit()
        __setupViewModelBinding()
        __setupViewOutActions()
    }
}

// MARK: - UITextViewDelegate

extension SuggestionViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        _viewModel.updateSuggestion(textView.text)
    }
}

// MARK: - Common Init

private extension SuggestionViewController {

    func __commonInit() {
        title = "建議回饋"
        navigationItem.leftBarButtonItem = _viewOutlet.cancelItem
        navigationItem.rightBarButtonItem = _viewOutlet.sendItem
        _viewOutlet.textView.delegate = self
    }
}

// MARK: - Setup ViewModel Binding

private extension SuggestionViewController {

    func __setupViewModelBinding() {
        _viewModel.$sendEnable
            .receive(on: DispatchQueue.main)
            .assign(to: \UIBarButtonItem.isEnabled, on: _viewOutlet.sendItem)
            .store(in: &_bindings)

        _viewModel.$suggestionType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?._viewModel.updateItemName("")
                self?._viewModel.updateItemAddress("")
                self?._viewModel.updateSuggestion("")
                self?._viewOutlet.reloadUIWithSuggestionType($0)
            }
            .store(in: &_bindings)
    }
}

// MARK: - Setup ViewOutlet Actions

private extension SuggestionViewController {

    func __setupViewOutActions() {
        _viewOutlet.cancelItem.target = self
        _viewOutlet.cancelItem.action = #selector(__cancelItemClicked)
        _viewOutlet.sendItem.target = self
        _viewOutlet.sendItem.action = #selector(__sendItemClicked)

        _viewOutlet.segment.addTarget(
            self,
            action: #selector(__segmentValueChanged(_:)),
            for: .valueChanged
        )

        _viewOutlet.nameField.addTarget(
            self,
            action: #selector(__nameFieldEditingChanged(_:)),
            for: .editingChanged
        )

        _viewOutlet.addressField.addTarget(
            self,
            action: #selector(__addressFieldEditingChanged(_:)),
            for: .editingChanged
        )
    }
}

// MARK: - ViewOutlet Actions

private extension SuggestionViewController {

    @objc func __cancelItemClicked() {
        dismiss(animated: true)
    }

    @objc func __sendItemClicked() {
        _viewModel.createGitHubIssue()
        dismiss(animated: true)
    }

    @objc func __segmentValueChanged(_ sender: UISegmentedControl) {
        _viewModel.updateSuggestionType(sender)
    }

    @objc func __nameFieldEditingChanged(_ sender: UITextField) {
        _viewModel.updateItemName(sender.text ?? "")
    }

    @objc func __addressFieldEditingChanged(_ sender: UITextField) {
        _viewModel.updateItemAddress(sender.text ?? "")
    }
}
