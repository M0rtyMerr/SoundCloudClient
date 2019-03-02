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

extension User {
    var avatar: URL? {
        return URL(string: avatarUrl ?? "")
    }
}
