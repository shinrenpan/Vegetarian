//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import Foundation

struct GeoJSON: Codable {

    struct Geometry: Codable {
        let coordinates: [Double]
    }

    struct Properties: Codable {
        let name: String
        let address: String
    }

    let features: [MapItem]
}
