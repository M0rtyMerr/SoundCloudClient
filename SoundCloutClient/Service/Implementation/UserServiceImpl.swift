//
//  UserServiceImpl.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Moya
import RxSwift

final class UserServiceImpl: UserService {
    private let soundCloudApi: MoyaProvider<SoundCloudApi>
    private let decoder: JSONDecoder

    init(soundCloudApi: MoyaProvider<SoundCloudApi>, decoder: JSONDecoder) {
        self.soundCloudApi = soundCloudApi
        self.decoder = decoder
    }

    func get(id: Int) -> Single<User> {
        return soundCloudApi.rx.request(.user(id: id)).map(User.self, using: decoder)
    }
}
