//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import UIKit

final class SuggestionViewModel {

    private(set) var text: String = "" {
        didSet {
            sendEnable = !text.isEmpty
        }
    }

    @Published private(set) var suggestionType = SuggestionType.suggestion
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

        var description: String {
            switch self {
            case .suggestion:
                return "請輸入建議事項"
            case .new:
                return "新增店家必須包含名稱與住址"
            }
        }
    }
}

// MARK: - Update Properties

extension SuggestionViewModel {

    func updateText(_ newValue: String) {
        text = newValue
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
        let parameters: [String: Any] = [
            "title": suggestionType.title,
            "labels": [suggestionType.gitHubLabel],
            "body": text,
        ]

        return try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
    }
}
