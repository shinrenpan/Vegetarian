//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import Combine
import Foundation
import MapKit

final class MapViewModel: NSObject {

    private(set) var totalItems = [MapItem]()

    private(set) var searchItems = [MapItem]()

    private(set) var selectedItems = [MapItem]()

    private(set) var location: CLLocation?

    @Published private(set) var totalItemState = TotalItemState.none

    @Published private(set) var searchItemState = SearchItemState.none

    @Published private(set) var selectedItemState = SelectItemState.none

    @Published private(set) var locationState = LocationState.none

    private lazy var _locationManager: CLLocationManager = {
        let result = CLLocationManager()
        result.delegate = self
        return result
    }()

    override init() {
        super.init()
        __setupTotalItems()
        __setupLocationState()

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.__setupLocationState()
        }
    }
}

// MARK: - Enum

extension MapViewModel {

    enum TotalItemState {
        case none
        case empty
        case downloading
        case downloadSuccess
        case downloadFailure
        case initSuccess
        case initFailure
    }

    enum SearchItemState {
        case none
        case empty
        case success
        case searching
    }

    enum SelectItemState {
        case none
        case empty
        case success
    }

    enum LocationState {
        case none
        case denied
        case error
        case notEnable
        case locating
        case located
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationState = .locating
            manager.startUpdatingLocation()
        case .denied:
            locationState = .denied
            location = nil
        case .restricted:
            locationState = .notEnable
            location = nil
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location_ = locations.last {
            location = location_
            locationState = .located
        }
        else {
            locationState = .error
        }

        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        location = nil
        locationState = .error
        manager.stopUpdatingLocation()
    }
}

// MARK: - Update Properties

extension MapViewModel {

    func updateSelectedItems(_ newValue: [MapItem]) {
        selectedItems = newValue
        selectedItemState = selectedItems.isEmpty ? .empty : .success
    }
}

// MARK: - Internal Functions

extension MapViewModel {

    func downloadTotalItems() {
        totalItemState = .downloading

        let url = Parameter.TotalItems

        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                self.__handleReponseData(data)
            }
        }
        .resume()
    }

    func locate() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationState = .locating
            _locationManager.startUpdatingLocation()
        }
        else {
            _locationManager.requestWhenInUseAuthorization()
        }
    }

    func search(center: CLLocation, radius: CLLocationDistance) {
        searchItemState = .searching

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            self.searchItems = self.totalItems.filter {
                let itemLocation = CLLocation(
                    latitude: $0.coordinate.latitude,
                    longitude: $0.coordinate.longitude
                )

                return center.distance(from: itemLocation) <= radius
            }

            self.searchItemState = self.searchItems.isEmpty ? .empty : .success
        }
    }
}

// MARK: - Handle Data

private extension MapViewModel {

    func __handleReponseData(_ data: Data?) {
        guard let data = data else {
            return totalItemState = .downloadFailure
        }

        do {
            let result = try JSONDecoder().decode(GeoJSON.self, from: data).features
            totalItems = result
            __writeTotalItemsToLocal()
        }
        catch {
            totalItemState = .downloadFailure
        }
    }

    func __writeTotalItemsToLocal() {
        do {
            let fileURL = try __makeTotalItemsFileURL()
            try JSONEncoder().encode(totalItems).write(to: fileURL, options: .atomic)
            totalItemState = .downloadSuccess
        }
        catch {
            totalItemState = .downloadFailure
        }
    }

    func __makeTotalItemsFileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("TotalItems.json")
    }
}

// MARK: - Setup

private extension MapViewModel {

    func __setupTotalItems() {
        do {
            let fileURL = try __makeTotalItemsFileURL()
            let data = try Data(contentsOf: fileURL)
            let result = try JSONDecoder().decode([MapItem].self, from: data)
            totalItems = result
            totalItemState = result.isEmpty ? .empty : .initSuccess
        }
        catch {
            totalItemState = .initFailure
        }
    }

    func __setupLocationState() {
        if CLLocationManager.locationServicesEnabled() == false {
            return locationState = .notEnable
        }

        switch CLLocationManager.authorizationStatus() {
        case .denied:
            locationState = .denied
        case .restricted:
            locationState = .notEnable
        default:
            locationState = .none
        }
    }
}
