//
//  ViewReactorTest.swift
//  SoundCloutClientTests
//
//  Created by Anton Nazarov on 04/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Moya
import Nimble
import Quick
import RxNimble
import RxSwift
import RxTest
@testable import SoundCloutClient

final class ViewReactorTest: QuickSpec {
    override func spec() {
        super.spec()

        describe("ViewReactor test") {
            var viewReactor: ViewReactor!
            var stubUserService: StubUserService!
            var stubTrackService: StubTrackService!
            var scheduler: TestScheduler!
            var observer: TestableObserver<ViewReactor.State>!
            var disposeBag: DisposeBag!

            context("stubbed services") {
                beforeEach {
                    stubUserService = StubUserService(stubUser: Random.user)
                    stubTrackService = StubTrackService(stubTracks: Random.tracks)
                    viewReactor = ViewReactor(userId: Random.int, userService: stubUserService, trackService: stubTrackService)
                    scheduler = TestScheduler(initialClock: 0)
                    observer = scheduler.createObserver(ViewReactor.State.self)
                    disposeBag = DisposeBag()
                    viewReactor.state.bind(to: observer).disposed(by: disposeBag)
                }

                it("loads user and tracks after init") {
                    // given
                    let expectedState = ViewReactor.State(
                        nextPage: stubTrackService.stubTracks.nextPage,
                        tracks: stubTrackService.stubTracks.collection,
                        user: stubUserService.stubUser
                    )
                    // then
                    expect(viewReactor.currentState) == expectedState
                }
                
                it("refreshes user and track after init") {
                    // given
                    let expectedUser = Random.user
                    let expectedTracks = Random.tracks
                    stubUserService.stubUser = expectedUser
                    stubTrackService.stubTracks = expectedTracks
                    // when
                    viewReactor.action.onNext(.refresh)
                    // then
                    expect(viewReactor.currentState.tracks) == expectedTracks.collection
                    expect(viewReactor.currentState.user) == expectedUser
                }

                it("loads more tracks after loadMore action") {
                    // given
                    let expectedTracks = stubTrackService.stubTracks.collection + stubTrackService.stubTracks.collection
                    // when
                    viewReactor.action.onNext(.loadMore)
                    // then
                    expect(viewReactor.currentState.tracks) == expectedTracks
                }
                
                it("change isRefresing correctly after refresh") {
                    // given
                    let stubTracksCount = stubTrackService.stubTracks.collection.count
                    let expectedStates = [
                        CountLoading(isLoading: false, trackCount: stubTracksCount),
                        CountLoading(isLoading: true, trackCount: stubTracksCount),
                        CountLoading(isLoading: false, trackCount: stubTracksCount)
                    ]
                    // when
                    viewReactor.action.onNext(.refresh)
                    // then
                    var actualStates: [CountLoading] {
                        return observer.elements.map { CountLoading(isLoading: $0.isRefreshing, trackCount: $0.tracks.count) }
                    }
                    expect(actualStates).toEventually(equal(expectedStates))
                }
                
                it("sets error to nil after refresh action") {
                    // given
                    stubTrackService.shouldReturnError = true
                    // when
                    viewReactor.action.onNext(.loadMore)
                    stubTrackService.shouldReturnError = false
                    viewReactor.action.onNext(.refresh)
                    // then
                    expect(viewReactor.currentState.error).to(beNil())
                }

                it("change isFooterLoading correctly after loadMore") {
                    // given
                    let stubTracksCount = stubTrackService.stubTracks.collection.count
                    let expectedStates = [
                        CountLoading(isLoading: false, trackCount: stubTracksCount),
                        CountLoading(isLoading: true, trackCount: stubTracksCount),
                        CountLoading(isLoading: true, trackCount: stubTracksCount * 2),
                        CountLoading(isLoading: false, trackCount: stubTracksCount * 2)
                    ]
                    // when
                    viewReactor.action.onNext(.loadMore)
                    // then
                    var actualStates: [CountLoading] {
                        return observer.elements.map { CountLoading(isLoading: $0.isFooterAnimating, trackCount: $0.tracks.count) }
                    }
                    expect(actualStates).toEventually(equal(expectedStates))
                }
                
                it("fires error if loading was unsuccess") {
                    // given
                    stubTrackService.shouldReturnError = true
                    // when
                    viewReactor.action.onNext(.refresh)
                    // then
                    expect(viewReactor.currentState.error).toEventuallyNot(beNil())
                }
            }
        }
    }
}

// MARK: - Private
private extension ViewReactorTest {
    final class StubUserService: UserService {
        var stubUser: User

        init(stubUser: User) {
            self.stubUser = stubUser
        }

        func get(id: Int) -> Single<User> {
            return .just(stubUser)
        }
    }

    final class StubTrackService: TrackService {
        var stubTracks: PaginatedResponse<Track>
        var shouldReturnError = false

        init(stubTracks: PaginatedResponse<Track>) {
            self.stubTracks = stubTracks
        }

        func get(userId: Int, pagination: Pagination) -> Single<PaginatedResponse<Track>> {
            return shouldReturnError ? .error(Random.error) :.just(stubTracks)
        }

        func get(href: URL) -> Single<PaginatedResponse<Track>> {
            return shouldReturnError ? .error(Random.error) :.just(stubTracks)
        }
    }
    
    struct CountLoading: Equatable {
        let isLoading: Bool
        let trackCount: Int
    }
}
