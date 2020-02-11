//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import CoreLocation
import UIKit

final class ListViewModel {

    let items: [MapItem]
    let userLocation: CLLocation?

    private(set) var actions = [ItemAction.searchInSafari]

    init(items: [MapItem], userLocation: CLLocation? = nil) {
        self.items = ListViewModel.__SortedItems(items, location: userLocation)
        self.userLocation = userLocation
        __checkCanActionOpenAppleMap()
        __checkCanActionOpenGoogleMap()
        actions.append(.bugReport)
    }
}

// MARK: - Enum

extension ListViewModel {

    enum ItemAction {
        case searchInSafari
        case openAppleMap
        case openGoogleMap
        case bugReport

        var title: String {
            switch self {
            case .searchInSafari:
                return "在瀏覽器搜尋"
            case .openAppleMap:
                return "在 Apple Map 開啟"
            case .openGoogleMap:
                return "在 Google Map 開啟"
            case .bugReport:
                return "錯誤回報"
            }
        }
    }
}

// MARK: - Check

private extension ListViewModel {

    func __checkCanActionOpenAppleMap() {
        if UIApplication.shared.canOpenURL(URL(string: "maps://")!) {
            actions.append(.openAppleMap)
        }
    }

    func __checkCanActionOpenGoogleMap() {
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            actions.append(.openGoogleMap)
        }
    }
}

// MARK: - Static functions

private extension ListViewModel {

    static func __SortedItems(_ items: [MapItem], location: CLLocation?) -> [MapItem] {
        guard let location = location else {
            return items
        }

        return items.sorted {
            let location1 = CLLocation(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude
            )

            let location2 = CLLocation(
                latitude: $1.coordinate.latitude,
                longitude: $1.coordinate.longitude
            )

            return location.distance(from: location1) < location.distance(from: location2)
        }
    }
}
