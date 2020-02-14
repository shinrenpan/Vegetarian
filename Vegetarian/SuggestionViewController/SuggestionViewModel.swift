//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import UIKit

final class SuggestionViewModel {

    private(set) var itemName: String = "" {
        didSet {
            __setupSendEnable()
        }
    }

    private var itemAddress: String = "" {
        didSet {
            __setupSendEnable()
        }
    }

    private(set) var suggestion: String = "" {
        didSet {
            __setupSendEnable()
        }
    }

    @Published private(set) var suggestionType = SuggestionType.suggestion {
        didSet {
            __setupSendEnable()
        }
    }

    @Published private(set) var sendEnable = false
}

// MARK: - Enum

extension SuggestionViewModel {

    enum SuggestionType: Int {
        case suggestion
        case new

        var title: String {
            switch self {
            case .suggestion:
                return "建議回饋"
            case .new:
                return "新增店家"
            }
        }

        var gitHubLabel: String {
            switch self {
            case .suggestion:
                return "Suggestion"
            case .new:
                return "New"
            }
        }
    }
}

// MARK: - Update Properties

extension SuggestionViewModel {

    func updateItemName(_ newValue: String) {
        itemName = newValue
    }

    func updateItemAddress(_ newValue: String) {
        itemAddress = newValue
    }

    func updateSuggestion(_ newValue: String) {
        suggestion = newValue
    }

    func updateSuggestionType(_ segment: UISegmentedControl) {
        suggestionType = SuggestionType(rawValue: segment.selectedSegmentIndex)!
    }
}

// MARK: - Internal Functions

extension SuggestionViewModel {

    func createGitHubIssue() {
        var request = URLRequest(url: Parameter.Suggestion(suggestionType))
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": Parameter.GitHubToken,
        ]

        request.httpBody = __makeRequestHTTPBody()
        URLSession.shared.dataTask(with: request).resume()
    }
}

// MARK: - Make Something

private extension SuggestionViewModel {

    func __makeRequestHTTPBody() -> Data? {
        var body: String

        switch suggestionType {
        case .suggestion:
            body = suggestion
        case .new:
            body = """
            店名: \(itemName)
            住址: \(itemAddress)
            """
        }

        let parameters: [String: Any] = [
            "title": suggestionType.title,
            "labels": [suggestionType.gitHubLabel],
            "body": body,
        ]

        return try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
    }
}

// MARK: - Setup

private extension SuggestionViewModel {

    func __setupSendEnable() {
        switch suggestionType {
        case .suggestion:
            sendEnable = !suggestion.isEmpty
        case .new:
            sendEnable = !itemName.isEmpty && !itemAddress.isEmpty
        }
    }
}
