//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import MapKit

final class MapItemClusterView: MKMarkerAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            __setupAnnotation(newValue)
        }
    }
}

// MARK: - Setup

private extension MapItemClusterView {

    func __setupAnnotation(_ annotation: MKAnnotation?) {
        guard let annotation = annotation as? MKClusterAnnotation else {
            return
        }

        displayPriority = .required
        annotation.title = nil
        annotation.subtitle = nil
    }
}
