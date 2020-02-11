//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import Combine
import GoogleMobileAds
import MapKit
import UIKit

final class MapViewController: UIViewController {

    private let _viewModel = MapViewModel()
    private let _viewOutlet = MapViewOutlet.FromXib()
    private var _bindings = Set<AnyCancellable>()
}

// MARK: - UIViewController Life Cycle

extension MapViewController {

    override func loadView() {
        view = _viewOutlet.mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _viewOutlet.mapView.delegate = self
        _viewOutlet.setupBannerForViewController(self)
        __setupViewModelBinding()
        __setupViewOutletActions()
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }

        guard let annotation = view.annotation else {
            return
        }

        var seleted: [MapItem]

        if let cluster = annotation as? MKClusterAnnotation {
            seleted = cluster.memberAnnotations as! [MapItem]
        }
        else {
            seleted = [annotation as! MapItem]
        }

        _viewModel.updateSelectedItems(seleted)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        _viewModel.updateSelectedItems([])
    }
}

// MARK: - GADBannerViewDelegate

extension MapViewController: GADBannerViewDelegate {

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if bannerView.isHidden {
            bannerView.isHidden = false
        }
    }
}

// MARK: - Setup ViewModel Binding

private extension MapViewController {

    func __setupViewModelBinding() {
        _viewModel.$totalItemState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.__handleTotalItemState($0)
            }
            .store(in: &_bindings)

        _viewModel.$searchItemState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.__handleSearchItemState($0)
            }
            .store(in: &_bindings)

        _viewModel.$locationState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.__handleLocationState($0)
            }
            .store(in: &_bindings)

        _viewModel.$selectedItemState
            .receive(on: DispatchQueue.main)
            .filter { $0 == .success }
            .sink { [weak self] in
                self?.__handleSelectItemState($0)
            }
            .store(in: &_bindings)
    }
}

// MARK: - Setup ViewOutlet Actions

private extension MapViewController {

    func __setupViewOutletActions() {
        _viewOutlet.locateButton.addTarget(self, action: #selector(__locateButtonClicked), for: .touchUpInside)
        _viewOutlet.searchButton.addTarget(self, action: #selector(__searchButtonClicked), for: .touchUpInside)
        _viewOutlet.downloadButton.addTarget(self, action: #selector(__downloadButtonClicked), for: .touchUpInside)
        _viewOutlet.suggestionButton.addTarget(self, action: #selector(__suggestionButtonClicked), for: .touchUpInside)
    }
}

// MARK: - Handle ViewModel State

private extension MapViewController {

    func __handleTotalItemState(_ state: MapViewModel.TotalItemState) {
        switch state {
        case .empty:
            _viewOutlet.reloadUIWithTotalItemStateEmpty()
        case .downloading:
            _viewOutlet.reloadUIWithTotalItemStateDownloading()
        case .downloadFailure:
            _viewOutlet.reloadUIWithTotalItemStateDownloadFailure(itemCount: _viewModel.totalItems.count)
        case .downloadSuccess:
            _viewOutlet.reloadUIWithTotalItemStateDownloadSuccess(itemCount: _viewModel.totalItems.count)
        case .initSuccess:
            _viewOutlet.reloadUIWithTotalItemStateInitSuccess(itemCount: _viewModel.totalItems.count)
        case .initFailure:
            _viewOutlet.reloadUIWithTotalItemStateInitFailure()
        case .none:
            break
        }
    }

    func __handleSearchItemState(_ state: MapViewModel.SearchItemState) {
        switch state {
        case .searching:
            _viewOutlet.reloadUIWithSearchItemStateSearching()
        case .empty:
            _viewOutlet.reloadUIWithSearchItemStateEmpty()
        case .success:
            _viewOutlet.reloadUIWithSearchItemStateSuccess(items: _viewModel.searchItems)
        case .none:
            break
        }
    }

    func __handleLocationState(_ state: MapViewModel.LocationState) {
        switch state {
        case .located:
            _viewOutlet.reloadUIWhenLocationStateLocated(_viewModel.location)
        case .denied:
            _viewOutlet.reloadUIWhenLocationStateDenied()
        case .notEnable:
            _viewOutlet.reloadUIWhenLocationStateNotEnable()
        default:
            _viewOutlet.reloadUIWhenLocationStateNone()
        }
    }

    func __handleSelectItemState(_ state: MapViewModel.SelectItemState) {
        let viewModel = ListViewModel(
            items: _viewModel.selectedItems,
            userLocation: _viewOutlet.mapView.userLocation.location
        )

        let vc = ListViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

// MARK: - ViewOutlet Actions

private extension MapViewController {

    @objc func __locateButtonClicked() {
        _viewModel.locate()
    }

    @objc func __searchButtonClicked() {
        let center = _viewOutlet.makeMapViewCenterLocation()
        let radius = _viewOutlet.makeMapViewScanRadius()
        _viewModel.search(center: center, radius: radius)
    }

    @objc func __downloadButtonClicked() {
        _viewModel.downloadTotalItems()
    }

    @objc func __suggestionButtonClicked() {
        let vc = SuggestionViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
