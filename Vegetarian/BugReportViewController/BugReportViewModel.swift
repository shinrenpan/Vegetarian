//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import UIKit

final class BugReportViewModel {

    let item: MapItem
    private var _bugType = BugType.name
    private var _text = ""

    init(item: MapItem) {
        self.item = item
    }
}

// MARK: - Enum

extension BugReportViewModel {

    enum BugType: Int {
        case name
        case address
        case etc

        var title: String {
            switch self {
            case .name:
                return "店家名稱錯誤"
            case .address:
                return "店家住址錯誤"
            case .etc:
                return "其他錯誤"
            }
        }

        var gitHubLabel: String {
            switch self {
            case .name:
                return "Bug_Name"
            case .address:
                return "Bug_Address"
            case .etc:
                return "Bug_ETC"
            }
        }
    }
}

// MARK: - Update Properties

extension BugReportViewModel {

    func updateBugType(segment: UISegmentedControl) {
        _bugType = BugType(rawValue: segment.selectedSegmentIndex)!
    }

    func updateText(_ newValue: String) {
        _text = newValue
    }
}

// MARK: - Internal Functions

extension BugReportViewModel {

    func createGitHubIssue() {
        var request = URLRequest(url: Parameter.BugReport)
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

private extension BugReportViewModel {

    func __makeRequestHTTPBody() -> Data? {
        let parameters: [String: Any] = [
            "title": _bugType.title,
            "labels": [_bugType.gitHubLabel],
            "body": """
                Id: \(item.id.uuidString)
                店名: \(item.properties.name)
                住址: \(item.properties.address)
                註記: \(_text)
            """,
        ]

        return try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
    }
}
