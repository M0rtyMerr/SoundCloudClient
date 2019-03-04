//
//  Random.swift
//  SoundCloutClientTests
//
//  Created by Anton Nazarov on 04/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Foundation
@testable import SoundCloutClient

enum Random {
    struct TestError: Error {
    }

    static var int: Int {
        return Int.random(in: 0..<6)
    }

    static var url: URL {
        // swiftlint:disable:next force_unwrapping
        return URL(string: "https://stackoverflow.com")!
    }

    static var string: String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...Random.int).compactMap { _ in letters.randomElement() })
    }

    static var user: User {
        return User(
            fullName: Random.string,
            avatarUrl: Random.string,
            publicFavoritesCount: Random.int,
            followersCount: Random.int
        )
    }

    static var track: Track {
        return Track(id: Random.int, title: Random.string, artworkUrl: Random.string)
    }

    static var tracks: PaginatedResponse<Track> {
        return PaginatedResponse<Track>(
            collection: Array(repeating: Random.track, count: Random.int),
            nextHref: Random.string
        )
    }

    static var error: Error {
        return TestError()
    }
}
