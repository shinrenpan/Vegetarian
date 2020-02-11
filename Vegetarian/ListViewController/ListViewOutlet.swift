//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import CoreLocation
import UIKit

final class ListViewOutlet: NSObject, ViewOutletable {

    @IBOutlet private(set) var mainView: UIView!
    @IBOutlet private(set) var tableView: UITableView! {
        didSet {
            __setupTableView()
        }
    }
}

// MARK: - Make Something

extension ListViewOutlet {

    func makeTableViewCell(item: MapItem, location: CLLocation?) -> ListViewCell {
        let cellName = "\(ListViewCell.self)"

        guard let result = tableView.dequeueReusableCell(withIdentifier: cellName) as? ListViewCell else {
            fatalError()
        }

        result.configure(item: item, location: location)

        return result
    }
}

// MARK: - Setup

private extension ListViewOutlet {

    func __setupTableView() {
        let cellName = "\(ListViewCell.self)"
        let nib = UINib(nibName: cellName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellName)
        tableView.tableFooterView = UIView(frame: .zero)
    }
}
