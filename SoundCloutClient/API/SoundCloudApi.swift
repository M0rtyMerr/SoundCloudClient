//
//  SoundCloudApi.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 01/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Moya

enum SoundCloudApi {
    case user(id: Int)
    case favorites(userId: Int, pagination: Pagination)
    case favoritesNext(href: URL)
}

// MARK: - TargetType
extension SoundCloudApi: TargetType {
    private enum Const {
        // в кейчейн после загрузки с бекенда в проде, но в тестовом норм
        static let userToken = "c23089b7e88643b5b839c4b8609fce3b"
    }

    var baseURL: URL {
        switch self {
        case .user, .favorites:
            guard let baseUrl = URL(string: "http://api.soundcloud.com") else {
                fatalError("Base URL is not correct")
            }
            return baseUrl
        case let .favoritesNext(href):
            return href
        }
    }

    var path: String {
        switch self {
        case  let .user(id):
            return "/users/\(id)"
        case let .favorites(userId, _):
            return "/users/\(userId)/favorites"
        case .favoritesNext:
            return "/"
        }
    }

    var method: Method {
        return .get
    }

    var sampleData: Data {
        switch self {
        case .favorites, .favoritesNext:
            return Util.json(named: "favoritesStub")
        case .user:
            return Util.json(named: "userStub")
        }
    }

    var task: Task {
        let token: [String: Any] = ["client_id": Const.userToken]
        switch self {
        case .user:
            return .requestParameters(parameters: token, encoding: URLEncoding.queryString)
        case let .favorites(_, pagination):
            let paginationMergedWithToken = token.merging(pagination.dictionary) { lhs, _ in lhs }
            return .requestParameters(parameters: paginationMergedWithToken, encoding: URLEncoding.queryString)
        case .favoritesNext:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return nil
    }
}
