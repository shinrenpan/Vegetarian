//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import MapKit

final class MapItem: NSObject, Codable, Identifiable {

    let id: UUID
    let geometry: GeoJSON.Geometry
    let properties: GeoJSON.Properties
}

// MARK: - MKAnnotation

extension MapItem: MKAnnotation {

    var title: String? {
        properties.name
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: geometry.coordinates.last!,
            longitude: geometry.coordinates.first!
        )
    }
}
