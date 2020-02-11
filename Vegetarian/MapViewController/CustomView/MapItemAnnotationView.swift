//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import MapKit

final class MapItemAnnotationView: MKMarkerAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            __setupAnnotation(newValue)
        }
    }
}

// MARK: - Setup

private extension MapItemAnnotationView {

    func __setupAnnotation(_ annotation: MKAnnotation?) {
        guard let _ = annotation as? MapItem else {
            return
        }

        clusteringIdentifier = "\(MapItemAnnotationView.self)"
        displayPriority = .required
        glyphImage = UIImage(named: "Leaf")
        markerTintColor = UIColor(named: "Leaf_Color")
    }
}
