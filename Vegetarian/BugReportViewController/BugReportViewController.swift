//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import Combine
import UIKit

final class BugReportViewController: UIViewController {

    private let _viewModel: BugReportViewModel
    private let _viewOutlet = BugReportViewOutlet.FromXib()

    init(viewModel: BugReportViewModel) {
        _viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewController Life Cycle

extension BugReportViewController {

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
        __setupViewOutletActions()
    }
}

// MARK: - UITextViewDelegate

extension BugReportViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        _viewModel.updateText(textView.text)
    }
}

// MARK: - Common Init

private extension BugReportViewController {

    func __commonInit() {
        title = "Bug 回報"
        navigationItem.leftBarButtonItem = _viewOutlet.cancelItem
        navigationItem.rightBarButtonItem = _viewOutlet.sendItem
        _viewOutlet.reloadUIWithItem(_viewModel.item)
        _viewOutlet.textView.delegate = self
        _viewOutlet.textView.becomeFirstResponder()
    }
}

// MARK: - Setup ViewOutlet Actions

private extension BugReportViewController {

    func __setupViewOutletActions() {
        _viewOutlet.cancelItem.target = self
        _viewOutlet.cancelItem.action = #selector(__cancelItemClicked)
        _viewOutlet.sendItem.target = self
        _viewOutlet.sendItem.action = #selector(__sendItemClicked)

        _viewOutlet.segment.addTarget(
            self,
            action: #selector(__segmentValueChanged(_:)),
            for: .valueChanged
        )
    }
}

// MARK: - ViewOutlet Actions

private extension BugReportViewController {

    @objc func __cancelItemClicked() {
        dismiss(animated: true)
    }

    @objc func __sendItemClicked() {
        _viewModel.createGitHubIssue()
        dismiss(animated: true)
    }

    @objc func __segmentValueChanged(_ sender: UISegmentedControl) {
        _viewModel.updateBugType(segment: sender)
        _viewModel.updateText("")
        _viewOutlet.textView.text = ""
    }
}
