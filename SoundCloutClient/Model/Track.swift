//
//  Track.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 01/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Differentiator
import Foundation

struct Track {
    let id: Int
    let title: String?
    let artworkUrl: String?
}

// MARK: - Decodable
extension Track: Decodable {
}

// MARK: - Equatable
extension Track: Equatable {
}

// MARK: - IdentifiableType
extension Track: IdentifiableType {
    var identity: Int {
        return id
    }
}

extension Track {
    var artwork: URL? {
        return URL(string: artworkUrl ?? "")
    }
}
