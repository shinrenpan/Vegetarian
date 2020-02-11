//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import UIKit

protocol ViewOutletable {}

// MARK: - Internal Functions

extension ViewOutletable where Self: NSObject {

    static func FromXib(named: String? = nil) -> Self {
        let result = Self()
        let named = named ?? "\(Self.self)"
        Bundle.main.loadNibNamed(named, owner: result, options: nil)
        return result
    }
}
