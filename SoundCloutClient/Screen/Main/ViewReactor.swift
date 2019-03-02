//
//  ViewReactor.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import ReactorKit
import RxCocoa
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
        static let interval: TimeInterval = 2 * 60
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
    }

    struct State {
        var nextPage: URL?
        var tracks: [Track] = []
        var error: String?
        var isFooterAnimating: Bool = false
        var user: User?
    }

    let initialState = State()
    private let userService: UserService
    private let trackService: TrackService
    private let userId: Int
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .background)

    init(userId: Int, userService: UserService, trackService: TrackService) {
        self.userService = userService
        self.trackService = trackService
        self.userId = userId
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return Observable.merge(
                userService.get(id: userId).map(Mutation.setUser).asObservable(),
                trackService.get(userId: userId, pagination: Pagination())
                    .map { Mutation.setTracks($0.collection, nextPage: $0.nextPage) }
                    .asObservable()
            )
        case .loadMore:
            guard let nextPage = currentState.nextPage else { return .empty() }
            return Observable.concat(
                .just(Mutation.setFooterAnimating(true)),
                trackService.get(href: nextPage).map { Mutation.appendTracks($0.collection, nextPage: $0.nextPage) }.asObservable(),
                .just(Mutation.setFooterAnimating(false))
            )
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
        }
        return newState
    }

    func transform(action: Observable<Action>) -> Observable<Action> {
        let periodicRefresh = Observable<Int>.interval(Const.interval, scheduler: backgroundScheduler).mapTo(Action.refresh)
        return Observable.merge(action.share().startWith(.refresh), periodicRefresh)
    }
}
