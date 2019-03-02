//
//  Track.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 01/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Foundation

struct Track {
    let title: String?
    private let artworkUrl: String?
    let streamUrl: String?
}

// MARK: - Decodable
extension Track: Decodable {
}

extension Track {
    var artwork: URL? {
        return URL(string: artworkUrl ?? "")
    }
}
