//
//  TrackServiceImpl.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Moya
import RxSwift

final class TrackServiceImpl: TrackService {
    private let soundCloudApi: MoyaProvider<SoundCloudApi>
    private let decoder: JSONDecoder

    init(soundCloudApi: MoyaProvider<SoundCloudApi>, decoder: JSONDecoder) {
        self.soundCloudApi = soundCloudApi
        self.decoder = decoder
    }

    func get(userId: Int, pagination: Pagination) -> Single<PaginatedResponse<Track>> {
        return soundCloudApi.rx.request(.favorites(userId: userId, pagination: pagination))
            .map(PaginatedResponse<Track>.self, using: decoder)
    }

    func get(href: URL) -> Single<PaginatedResponse<Track>> {
        return soundCloudApi.rx.request(.favoritesNext(href: href))
            .map(PaginatedResponse<Track>.self, using: decoder)
    }
}
