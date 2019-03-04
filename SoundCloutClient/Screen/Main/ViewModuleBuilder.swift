//
//  ViewModuleBuilder.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 04/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Foundation
import Moya

final class ViewModuleBuilder {
    private let userId: Int
    private let refreshPeriod: TimeInterval

    init(userId: Int, refreshPeriod: TimeInterval) {
        self.userId = userId
        self.refreshPeriod = refreshPeriod
    }

    func build() -> ViewController {
        let soundCloudApi = MoyaProvider<SoundCloudApi>(
            plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)]
        )
        let decoder = JSONDecoder().then {
            $0.keyDecodingStrategy = .convertFromSnakeCase
        }
        let userService = UserServiceImpl(soundCloudApi: soundCloudApi, decoder: decoder)
        let trackService = TrackServiceImpl(soundCloudApi: soundCloudApi, decoder: decoder)
        let viewReactor = ViewReactor(userId: userId, userService: userService, trackService: trackService, refreshPeriod: refreshPeriod)
        return ViewController.instantiate().then {
            $0.reactor = viewReactor
        }
    }

    private func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data
        }
    }
}
