//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import UIKit

final class SuggestionViewOutlet: NSObject, ViewOutletable {

    @IBOutlet private(set) var mainView: UIView!

    @IBOutlet private(set) var textView: UITextView! {
        didSet {
            __setupTextView()
        }
    }

    @IBOutlet private(set) var textViewBottom: NSLayoutConstraint!
    @IBOutlet private(set) var segment: UISegmentedControl!
    @IBOutlet private(set) var descriptionLabel: UILabel!

    private(set) lazy var cancelItem: UIBarButtonItem = {
        UIBarButtonItem(title: "離開", style: .done, target: nil, action: nil)
    }()

    private(set) lazy var sendItem: UIBarButtonItem = {
        UIBarButtonItem(title: "送出", style: .plain, target: nil, action: nil)
    }()
}

// MARK: - Reload UI

extension SuggestionViewOutlet {

    func reloadUIWhenKeyboardDidChangeFrame(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let beginFrameValue = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)!
        let beginFrame = beginFrameValue.cgRectValue
        let endFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
        let endFrame = endFrameValue.cgRectValue

        if beginFrame.equalTo(endFrame) {
            return
        }
        else {
            textViewBottom.constant = endFrame.height + 8
        }
    }

    func reloadUIWithSuggestionType(_ type: SuggestionViewModel.SuggestionType) {
        textView.text = ""
        sendItem.isEnabled = false
        descriptionLabel.text = type.description
    }
}

// MARK: - Setup

private extension SuggestionViewOutlet {

    func __setupTextView() {
        textView.layer.masksToBounds = true
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.borderWidth = 0.6
        textView.layer.cornerRadius = 10
    }
}
