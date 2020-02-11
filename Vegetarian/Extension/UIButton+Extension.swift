//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import UIKit

extension UIButton {

    func centerVertically(padding: CGFloat = 6) {
        guard
            let imageViewSize = imageView?.frame.size,
            let titleLabelSize = titleLabel?.frame.size else {
            return
        }

        let totalHeight = imageViewSize.height + titleLabelSize.height + padding * 3

        imageEdgeInsets = UIEdgeInsets(
            top: -padding, // -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )

        titleEdgeInsets = UIEdgeInsets(
            top: padding,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )

        contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
}
