//
//  TrackServiceTest.swift
//  SoundCloutClientTests
//
//  Created by Anton Nazarov on 04/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Moya
import Nimble
import Quick
import RxNimble
@testable import SoundCloutClient

final class TrackServiceTest: QuickSpec {
    override func spec() {
        super.spec()

        describe("TrackService test") {
            var trackService: TrackService!

            context("stubbed provider") {
                beforeEach {
                    let decoder = JSONDecoder().then {
                        $0.keyDecodingStrategy = .convertFromSnakeCase
                    }
                    let stubProvider = MoyaProvider<SoundCloudApi>(stubClosure: MoyaProvider.immediatelyStub)
                    trackService = TrackServiceImpl(soundCloudApi: stubProvider, decoder: decoder)
                }

                afterEach {
                    trackService = nil
                }

                it("get(userId:) returns tracks from stub") {
                    let stubTrackCount = 3
                    let actualTrackCount = trackService.get(userId: Random.int, pagination: Pagination())
                        .map { $0.collection.count }
                        .asObservable()

                    expect(actualTrackCount).first == stubTrackCount
                }

                it("get(href:) returns tracks from stub") {
                    let stubTrackCount = 3
                    let actualTrackCount = trackService.get(href: Random.url)
                        .map { $0.collection.count }
                        .asObservable()

                    expect(actualTrackCount).first == stubTrackCount
                }
            }
        }
    }
}
