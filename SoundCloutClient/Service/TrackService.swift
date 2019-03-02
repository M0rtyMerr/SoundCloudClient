//
//  TrackService.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import RxSwift

protocol TrackService {
    func get(userId: Int, pagination: Pagination) -> Single<PaginatedResponse<Track>>
    func get(href: URL) -> Single<PaginatedResponse<Track>>
}
