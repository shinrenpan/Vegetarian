//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import UIKit

extension UIView {

    final func startRipple(color: UIColor = .systemBlue, repeatCount: Float = HUGE) {
        var frame = bounds
        let minSide = min(bounds.width, bounds.height)
        frame.size.width = minSide
        frame.size.height = minSide

        let circle = CAShapeLayer()
        circle.frame = frame
        circle.path = UIBezierPath(ovalIn: frame).cgPath
        circle.fillColor = color.cgColor
        circle.opacity = 0.0
        circle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circle.position = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)

        let replicator = CAReplicatorLayer()
        replicator.instanceCount = 4
        replicator.instanceDelay = 1.0
        replicator.addSublayer(circle)
        replicator.name = "Ripple"

        layer.addSublayer(replicator)

        CATransaction.begin()

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.3
        opacityAnimation.toValue = 0.0

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        animationGroup.duration = 4.0
        animationGroup.repeatCount = repeatCount
        animationGroup.isRemovedOnCompletion = true
        animationGroup.timingFunction =
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)

        CATransaction.setCompletionBlock {
            self.stopRipple()
        }

        circle.add(animationGroup, forKey: nil)

        CATransaction.commit()
    }

    final func stopRipple() {
        guard let layer = layer.sublayers?.first(where: { $0.name == "Ripple" }) else {
            return
        }

        layer.removeAllAnimations()
        layer.removeFromSuperlayer()
    }
}
