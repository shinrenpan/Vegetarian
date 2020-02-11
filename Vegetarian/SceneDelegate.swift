//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder {

    var window: UIWindow?
}

extension SceneDelegate: UIWindowSceneDelegate {

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else {
            fatalError()
        }

        let window = UIWindow(windowScene: scene)
        window.rootViewController = MapViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}
