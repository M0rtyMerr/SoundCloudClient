//
//  User.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Foundation

struct User {
    let fullName: String?
    let avatarUrl: String?
    let publicFavoritesCount: Int?
    let followersCount: Int?
}

// MARK: - Decodable
extension User: Decodable {
}

// MARK: - Equatable
extension User: Equatable {
}

extension User {
    var avatar: URL? {
        return URL(string: avatarUrl ?? "")
    }

    var publicFavoritesCountText: String? {
        guard let publicFavoritesCount = publicFavoritesCount else { return nil }
        return String(publicFavoritesCount)
    }

    var followersCountText: String? {
        guard let followersCount = followersCount else { return nil }
        return String(followersCount)
    }
}
