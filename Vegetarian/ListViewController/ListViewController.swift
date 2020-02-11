//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import MapKit
import SafariServices
import UIKit

final class ListViewController: UIViewController {

    private let _viewModel: ListViewModel
    private let _viewOutlet = ListViewOutlet.FromXib()

    init(viewModel: ListViewModel) {
        _viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIViewController Life Cycle

extension ListViewController {

    override func loadView() {
        view = _viewOutlet.mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _viewOutlet.tableView.delegate = self
        _viewOutlet.tableView.dataSource = self
        title = "共有 \(_viewModel.items.count) 家店家"
    }
}

// MARK: - UITableViewDataSource

extension ListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        _viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        _viewOutlet.makeTableViewCell(
            item: _viewModel.items[indexPath.row],
            location: _viewModel.userLocation
        )
    }
}

// MARK: - UITableViewDelegate

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = _viewModel.items[indexPath.row]
        __presentActionSheet(item: item)
    }
}

// MARK: - Present ViewController

private extension ListViewController {

    func __presentActionSheet(item: MapItem) {
        let sheet = UIAlertController(title: "更多...", message: nil, preferredStyle: .actionSheet)

        for action in _viewModel.actions {
            let action_ = __makeAlertAction(type: action, item: item)
            sheet.addAction(action_)
        }

        let cancel = UIAlertAction(title: "取消", style: .cancel)
        sheet.addAction(cancel)
        present(sheet, animated: true)
    }

    func __presentSafariViewController(item: MapItem) {
        let url = Parameter.Google(item)
        let sarafiVC = SFSafariViewController(url: url)
        present(sarafiVC, animated: true)
    }

    func __presentBugReportViewController(item: MapItem) {
        let viewModel = BugReportViewModel(item: item)
        let vc = BugReportViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

// MARK: - Make Something

private extension ListViewController {

    func __makeAlertAction(type: ListViewModel.ItemAction, item: MapItem) -> UIAlertAction {
        let result = UIAlertAction(title: type.title, style: .default) { [weak self] _ in
            switch type {
            case .searchInSafari:
                self?.__presentSafariViewController(item: item)
            case .openAppleMap:
                self?.__openAppleMap(item: item)
            case .openGoogleMap:
                self?.__openGoogleMap(item: item)
            case .bugReport:
                self?.__presentBugReportViewController(item: item)
            }
        }

        return result
    }
}

// MARK: - Open Other App

private extension ListViewController {

    func __openAppleMap(item: MapItem) {
        let mark = MKPlacemark(coordinate: item.coordinate)
        let mapItem = MKMapItem(placemark: mark)
        mapItem.name = item.title
        mapItem.openInMaps(launchOptions: nil)
    }

    func __openGoogleMap(item: MapItem) {
        let url = Parameter.GoogleMap(item)
        UIApplication.shared.open(url, options: [:])
    }
}
