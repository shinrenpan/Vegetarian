//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import CoreLocation
import UIKit

final class ListViewCell: UITableViewCell {

    @IBOutlet private(set) var nameLabel: UILabel!
    @IBOutlet private(set) var addressLabel: UILabel!
    @IBOutlet private(set) var distanceLabel: UILabel!
}

// MARK: - Internal Functions

extension ListViewCell {

    func configure(item: MapItem, location: CLLocation?) {
        nameLabel.text = item.properties.name
        addressLabel.text = item.properties.address

        guard let location = location else {
            return distanceLabel.text = nil
        }

        let itemLocation = CLLocation(
            latitude: item.coordinate.latitude,
            longitude: item.coordinate.longitude
        )

        let distance = location.distance(from: itemLocation)
        let distanceStr = distance >= 1000
            ? String(format: "%.1f公里", distance / 1000)
            : String(format: "%.0f公尺", distance)

        distanceLabel.text = "距離你: \(distanceStr)"
    }
}
