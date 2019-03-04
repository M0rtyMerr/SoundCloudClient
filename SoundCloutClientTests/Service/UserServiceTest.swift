//
//  UserServiceTest.swift
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

final class UserServiceTest: QuickSpec {
    override func spec() {
        super.spec()

        describe("UserService test") {
            // swiftlint:disable:next implicitly_unwrapped_optional
            var userService: UserService!

            context("stubbed provider") {
                beforeEach {
                    let decoder = JSONDecoder().then {
                        $0.keyDecodingStrategy = .convertFromSnakeCase
                    }
                    let stubProvider = MoyaProvider<SoundCloudApi>(stubClosure: MoyaProvider.immediatelyStub)
                    userService = UserServiceImpl(soundCloudApi: stubProvider, decoder: decoder)
                }

                afterEach {
                    userService = nil
                }

                it("get(id:) returns user from stub") {
                    let stubUserName = "Johannes Wagener"
                    let actualUserName = userService.get(id: Random.int).map { $0.fullName }.asObservable()

                    expect(actualUserName).first == stubUserName
                }
            }
        }
    }
}
