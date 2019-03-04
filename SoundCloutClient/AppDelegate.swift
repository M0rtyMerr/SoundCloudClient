//
//  AppDelegate.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 01/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Moya
import RxSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private enum Const {
        static let userId = 3_207
        static let refreshPeriod: TimeInterval = 2 * 60
    }

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow().then {
            $0.backgroundColor = .white
            $0.makeKeyAndVisible()
            $0.rootViewController = ViewModuleBuilder(userId: Const.userId, refreshPeriod: Const.refreshPeriod).build()
        }
        return true
    }
}
