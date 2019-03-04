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
    }

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow().then {
            $0.backgroundColor = .white
            $0.makeKeyAndVisible()
            $0.rootViewController = buildViewController()
        }
        return true
    }
}

// MARK: - Private
private extension AppDelegate {
    func buildViewController() -> ViewController {
        let soundCloudApi = MoyaProvider<SoundCloudApi>(
            plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)]
        )
        let decoder = JSONDecoder().then {
            $0.keyDecodingStrategy = .convertFromSnakeCase
        }
        let userService = UserServiceImpl(soundCloudApi: soundCloudApi, decoder: decoder)
        let trackService = TrackServiceImpl(soundCloudApi: soundCloudApi, decoder: decoder)
        let viewReactor = ViewReactor(userId: Const.userId, userService: userService, trackService: trackService, refreshPeriod: 2 * 60)
        return ViewController.instantiate().then {
            $0.reactor = viewReactor
        }
    }

    func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data
        }
    }
}
