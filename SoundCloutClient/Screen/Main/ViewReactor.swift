//
//  ViewReactor.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import RxSwiftExt

// Ревьюеверам
// Я не написал лично, ибо заметил проблему только в самом конце
// Срочно нужно менять апи для тестового задания. Саундклауд возвращает только публичные треки, но при этом
// счетчик идет и по приватным. Поэтому есть шанс вместо запрошенного лимита получить пустую коллекцию
// при этом следующая страница (href) будет уже не пустая. Например
// https://api.soundcloud.com/users/3207/tracks?linked_partitioning=1&limit=3&offset=13&client_id=c23089b7e88643b5b839c4b8609fce3b
// Никаких претензий, всем мир, но на мой взгляд это иррационально усложняет задание. Будь это мой проект, я бы просто пошел
// подрался с бекендером и он бы сделал нормальный индекс по публичным трекам

final class ViewReactor: Reactor {
    private enum Const {
        static let error = "Sorry, error"
    }

    enum Action {
        case refresh
        case loadMore
    }

    enum Mutation {
        case setTracks([Track], nextPage: URL?)
        case appendTracks([Track], nextPage: URL?)
        case setUser(User)
        case setFooterAnimating(Bool)
        case setRefresing(Bool)
        case setError(String?)
    }

    struct State: Equatable {
        typealias SectionType = AnimatableSectionModel<String, Track>

        var nextPage: URL?
        var tracks: [Track] = []
        var error: String?
        var isRefreshing: Bool = false
        var isFooterAnimating: Bool = false
        var user: User?
        var sections: [SectionType] {
            return [SectionType(model: "", items: tracks)]
        }

        init(nextPage: URL? = nil, tracks: [Track] = [], error: String? = nil, isFooterAnimating: Bool = false, user: User? = nil, isRefreshing: Bool = false) {
            self.nextPage = nextPage
            self.tracks = tracks
            self.error = error
            self.isFooterAnimating = isFooterAnimating
            self.user = user
            self.isRefreshing = isRefreshing
        }
    }

    let initialState = State()
    private let refreshPeriod: TimeInterval?
    private let userService: UserService
    private let trackService: TrackService
    private let userId: Int
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .background)

    init(userId: Int, userService: UserService, trackService: TrackService, refreshPeriod: TimeInterval? = nil) {
        self.userService = userService
        self.trackService = trackService
        self.userId = userId
        self.refreshPeriod = refreshPeriod
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            let refreshTracksAndUser = Observable.merge(
                userService.get(id: userId).map(Mutation.setUser).asObservable(),
                trackService.get(userId: userId, pagination: Pagination())
                    .map { Mutation.setTracks($0.collection, nextPage: $0.nextPage) }
                    .asObservable()
            )
            .catchErrorJustReturn(Mutation.setError(Const.error))

            return Observable.concat(
                 .just(Mutation.setError(nil)),
                 .just(Mutation.setRefresing(true)),
                 refreshTracksAndUser,
                 .just(Mutation.setRefresing(false))
            )
        case .loadMore:
            guard let nextPage = currentState.nextPage else { return .empty() }
            return Observable.concat(
                .just(Mutation.setFooterAnimating(true)),
                trackService.get(href: nextPage).map { Mutation.appendTracks($0.collection, nextPage: $0.nextPage) }.asObservable(),
                .just(Mutation.setFooterAnimating(false))
            )
            .catchErrorJustReturn(Mutation.setError(Const.error))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setUser(user):
            newState.user = user
        case let .setFooterAnimating(isFooterAnimating):
            newState.isFooterAnimating = isFooterAnimating
        case let .setTracks(tracks, nextPage):
            newState.tracks = tracks
            newState.nextPage = nextPage
        case let .appendTracks(tracks, nextPage):
            newState.tracks.append(contentsOf: tracks)
            newState.nextPage = nextPage
        case let .setError(error):
            newState.error = error
        case let .setRefresing(isRefreshing):
            newState.isRefreshing = isRefreshing
        }
        return newState
    }

    func transform(action: Observable<Action>) -> Observable<Action> {
        let initialAction = action.share().startWith(.refresh)
        guard let refreshPeriod = refreshPeriod else {
            return initialAction
        }
        let periodicRefresh = Observable<Int>.interval(refreshPeriod, scheduler: backgroundScheduler).mapTo(Action.refresh)
        return Observable.merge(initialAction, periodicRefresh)
    }
}
