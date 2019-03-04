//
//  Pagination.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 01/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

struct Pagination {
    private enum Const {
        static let defaultLimit = 50
        static let defaultLinkedPartitioning = 1
    }

    let limit: Int
    let linkedPartitioning: Int

    init(limit: Int = Const.defaultLimit, linkedPartitioning: Int = Const.defaultLinkedPartitioning) {
        self.limit = limit
        self.linkedPartitioning = linkedPartitioning
    }

    var dictionary: [String: Any] {
        return [
            "limit": limit,
            "linked_partitioning": linkedPartitioning
        ]
    }
}

// MARK: - Encodable
extension Pagination: Encodable {
}
