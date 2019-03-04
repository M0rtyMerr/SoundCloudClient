//
//  PaginatedResponse.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Foundation

struct PaginatedResponse<T: Decodable> {
    let collection: [T]
    let nextHref: String?
}

// MARK: - Decodable
extension PaginatedResponse: Decodable {
}

extension PaginatedResponse {
    var nextPage: URL? {
        return URL(string: nextHref ?? "")
    }
}
