//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import UIKit

final class SuggestionViewOutlet: NSObject, ViewOutletable {

    @IBOutlet private(set) var mainView: UIView!
    @IBOutlet private(set) var segment: UISegmentedControl!
    @IBOutlet private(set) var textViewTitle: UILabel!

    @IBOutlet private(set) var textView: UITextView! {
        didSet {
            __setupTextView()
        }
    }

    @IBOutlet private(set) var nameTitle: UILabel!
    @IBOutlet private(set) var nameField: UITextField!
    @IBOutlet private(set) var addressTitle: UILabel!
    @IBOutlet private(set) var addressField: UITextField!
    @IBOutlet private(set) var stackBottom: NSLayoutConstraint!

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
        if textView.isHidden {
            return
        }

        let userInfo = notification.userInfo!
        let beginFrameValue = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)!
        let beginFrame = beginFrameValue.cgRectValue
        let endFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
        let endFrame = endFrameValue.cgRectValue

        if beginFrame.equalTo(endFrame) {
            return
        }
        else {
            stackBottom.constant = endFrame.height + 8
        }
    }

    func reloadUIWithSuggestionType(_ type: SuggestionViewModel.SuggestionType) {
        nameField.text = ""
        addressField.text = ""
        textView.text = ""

        switch type {
        case .suggestion:
            nameTitle.isHidden = true
            nameField.isHidden = true
            addressTitle.isHidden = true
            addressField.isHidden = true
            textViewTitle.isHidden = false
            textView.isHidden = false
            textView.becomeFirstResponder()
        case .new:
            nameTitle.isHidden = false
            nameField.isHidden = false
            addressTitle.isHidden = false
            addressField.isHidden = false
            textViewTitle.isHidden = true
            textView.isHidden = true
            nameField.becomeFirstResponder()
        }
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
