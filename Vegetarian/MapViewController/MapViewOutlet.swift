//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import GoogleMobileAds
import MapKit
import UIKit

final class MapViewOutlet: NSObject, ViewOutletable {

    @IBOutlet private(set) var mainView: UIView!
    @IBOutlet private(set) var banner: GADBannerView!

    @IBOutlet private(set) var mapView: MKMapView! {
        didSet {
            __setupMapView()
        }
    }

    @IBOutlet private(set) var toast: UIView! {
        didSet {
            __setupToast()
        }
    }

    @IBOutlet private(set) var toastLabel: UILabel!

    @IBOutlet private(set) var locateButton: UIButton! {
        didSet {
            locateButton.centerVertically()
        }
    }

    @IBOutlet private(set) var searchButton: UIButton! {
        didSet {
            searchButton.centerVertically()
        }
    }

    @IBOutlet private(set) var downloadButton: UIButton! {
        didSet {
            downloadButton.centerVertically()
        }
    }

    @IBOutlet private(set) var suggestionButton: UIButton! {
        didSet {
            suggestionButton.centerVertically()
        }
    }
}

// MARK: - Setup

extension MapViewOutlet {

    func setupBannerForViewController(_ vc: GADBannerViewDelegate) {
        if let vc = vc as? UIViewController {
            banner.rootViewController = vc
        }

        banner.adUnitID = Parameter.AdMobUID
        banner.delegate = vc

        GADMobileAds.sharedInstance()
            .requestConfiguration
            .testDeviceIdentifiers = [kGADSimulatorID as! String]

        banner.load(GADRequest())
    }
}

// MARK: - Reload UI By TotalItem State

extension MapViewOutlet {

    func reloadUIWithTotalItemStateEmpty() {
        searchButton.isEnabled = false
        downloadButton.isEnabled = true
        downloadButton.tintColor = .systemRed
        suggestionButton.isEnabled = true
        __setupLocateButtonEnable()
    }

    func reloadUIWithTotalItemStateInitSuccess(itemCount: Int) {
        searchButton.isEnabled = true
        downloadButton.isEnabled = true
        downloadButton.tintColor = .systemBlue
        suggestionButton.isEnabled = true
        __setupLocateButtonEnable()
        __showToastWithText("初始資料成功\n本地端共有 \(itemCount) 筆資料", color: .label)
    }

    func reloadUIWithTotalItemStateDownloadSuccess(itemCount: Int) {
        searchButton.isEnabled = true
        downloadButton.isEnabled = true
        downloadButton.tintColor = .systemBlue
        suggestionButton.isEnabled = true
        __setupLocateButtonEnable()
        __showToastWithText("下載資料成功\n本地端共有 \(itemCount) 筆資料", color: .label)
    }

    func reloadUIWithTotalItemStateDownloading() {
        locateButton.isEnabled = false
        searchButton.isEnabled = false
        downloadButton.isEnabled = false
        suggestionButton.isEnabled = false
        __showToastWithText("下載資料中...", color: .label, autoHidden: false)
    }

    func reloadUIWithTotalItemStateDownloadFailure(itemCount: Int) {
        searchButton.isEnabled = itemCount > 0 ? true : false
        downloadButton.isEnabled = true
        downloadButton.tintColor = itemCount > 0 ? .systemBlue : .systemRed
        suggestionButton.isEnabled = true
        __setupLocateButtonEnable()

        var text: String
        var color: UIColor
        var hidden: Bool

        if itemCount > 0 {
            text = "下載資料失敗\n本地端共有 \(itemCount) 筆資料"
            color = .label
            hidden = true
        }
        else {
            text = "下載資料失敗\n請檢查網路連線"
            color = .systemRed
            hidden = false
        }

        __showToastWithText(text, color: color, autoHidden: hidden)
    }

    func reloadUIWithTotalItemStateInitFailure() {
        searchButton.isEnabled = false
        downloadButton.isEnabled = true
        downloadButton.tintColor = .systemRed
        suggestionButton.isEnabled = true
        __setupLocateButtonEnable()
        __showToastWithText("初始化資料失敗\n請點擊資料更新.", color: .systemRed, autoHidden: false)
    }
}

// MARK: - Reload UI By SearchItem State

extension MapViewOutlet {

    func reloadUIWithSearchItemStateEmpty() {
        mapView.isUserInteractionEnabled = true
        searchButton.isEnabled = true
        downloadButton.isEnabled = true
        suggestionButton.isEnabled = true
        __setupLocateButtonEnable()
        mapView.stopRipple()
        let radiusText = __makeMapViewScanRadiusText()

        __showToastWithText("中心點半徑 \(radiusText)內\n沒有任何店家", color: .label)
    }

    func reloadUIWithSearchItemStateSuccess(items: [MapItem]) {
        mapView.isUserInteractionEnabled = true
        searchButton.isEnabled = true
        downloadButton.isEnabled = true
        suggestionButton.isEnabled = true
        __setupLocateButtonEnable()
        mapView.stopRipple()
        mapView.addAnnotations(items)
        let radiusText = __makeMapViewScanRadiusText()

        __showToastWithText("中心點半徑 \(radiusText)內\n共有 \(items.count) 間店家", color: .label)
    }

    func reloadUIWithSearchItemStateSearching() {
        mapView.isUserInteractionEnabled = false
        locateButton.isEnabled = false
        searchButton.isEnabled = false
        downloadButton.isEnabled = false
        suggestionButton.isEnabled = false
        let shouldRemove = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(shouldRemove)
        mapView.startRipple()
    }
}

// MARK: - Reload UI By Location State

extension MapViewOutlet {

    func reloadUIWhenLocationStateLocated(_ location: CLLocation?) {
        guard let location = location else {
            return
        }

        let region = __makeLocateCoordinateRegion(location: location)

        mapView.setRegion(region, animated: true)
    }

    func reloadUIWhenLocationStateNone() {
        __setupLocateButtonEnable()
    }

    func reloadUIWhenLocationStateDenied() {
        __setupLocateButtonEnable()
    }

    func reloadUIWhenLocationStateNotEnable() {
        __setupLocateButtonEnable()
    }
}

// MARK: - Make Something

extension MapViewOutlet {

    func makeMapViewCenterLocation() -> CLLocation {
        CLLocation(
            latitude: mapView.centerCoordinate.latitude,
            longitude: mapView.centerCoordinate.longitude
        )
    }

    func makeMapViewScanRadius() -> CLLocationDistance {
        let maxSide = max(mapView.bounds.width, mapView.bounds.height)
        let maxSidePoint = CGPoint(x: 0, y: maxSide / 2.0)
        let maxSidePointCoordinate = mapView.convert(maxSidePoint, toCoordinateFrom: mapView)

        let maxSidePointLocation = CLLocation(
            latitude: maxSidePointCoordinate.latitude,
            longitude: maxSidePointCoordinate.longitude
        )

        let centerLocation = makeMapViewCenterLocation()
        let result = centerLocation.distance(from: maxSidePointLocation)

        return (result < 2000) ? result : 2000
    }
}

// MARK: - Private Setup

private extension MapViewOutlet {

    func __setupMapView() {
        
        // 原生的指南針會擋到, 所以新增一個不會擋到的指南針
        mapView.showsCompass = false
        let compass = MKCompassButton(mapView:mapView)
        compass.compassVisibility = .adaptive
        compass.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(compass)
        let safeArea = mainView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            compass.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            compass.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8)
        ])
        
        mapView.showsUserLocation = true

        // 阻止 UserLocation show callout
        mapView.userLocation.title = ""

        let annotationId = MKMapViewDefaultAnnotationViewReuseIdentifier
        mapView.register(
            MapItemAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: annotationId
        )

        let clusterId = MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        mapView.register(
            MapItemClusterView.self,
            forAnnotationViewWithReuseIdentifier: clusterId
        )
    }

    func __setupToast() {
        toast.layer.masksToBounds = true
        toast.layer.cornerRadius = 10
    }

    func __setupLocateButtonEnable() {
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            locateButton.isEnabled = false
        default:
            locateButton.isEnabled = true
        }
    }
}

// MARK: - Handle Toast

private extension MapViewOutlet {

    func __showToastWithText(_ text: String, color: UIColor, autoHidden: Bool = true) {
        let selector = #selector(__hideToast)

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: selector, object: nil)

        toastLabel.text = text
        toastLabel.textColor = color
        toast.isHidden = false

        if autoHidden == false {
            return
        }

        perform(selector, with: nil, afterDelay: 2.6)
    }

    @objc func __hideToast() {
        toast.isHidden = true
    }
}

// MARK: - Private Make Something

private extension MapViewOutlet {

    func __makeMapViewScanRadiusText() -> String {
        let radius = makeMapViewScanRadius()

        if radius >= 1000 {
            return String(format: "%.1f 公里", radius / 1000)
        }

        return String(format: "%.0f 公尺", radius)
    }

    func __makeLocateCoordinateRegion(location: CLLocation) -> MKCoordinateRegion {
        var span = mapView.region.span

        print(span)

        if span.latitudeDelta > 0.03 && span.longitudeDelta > 0.03 {
            span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        }

        return MKCoordinateRegion(center: location.coordinate, span: span)
    }
}
