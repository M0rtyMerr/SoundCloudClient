//
//  ViewController.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 01/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import AVKit
import ReactorKit
import Reusable
import RxDataSources
import RxSwift
import Then
import UIKit

final class ViewController: UIViewController, StoryboardBased, StoryboardView {
    @IBOutlet private var tableView: UITableView!
    private lazy var userView = UserView.loadFromNib()
    private let footerActivityIndicator = UIActivityIndicatorView(style: .gray).then {
        $0.frame = CGRect(x: 0, y: 0, width: 0, height: 30)
    }
    private lazy var refreshControl = UIRefreshControl()

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.do {
            $0.register(cellType: TrackTableViewCell.self)
            $0.tableHeaderView = userView
            $0.refreshControl = refreshControl
            $0.refreshControl?.beginRefreshing()
            $0.tableFooterView = footerActivityIndicator
        }
    }

    func bind(reactor: ViewReactor) {
        refreshControl.rx
            .controlEvent(.valueChanged)
            .mapTo(ViewReactor.Action.refresh)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        tableView.rx.reachedBottom
            .throttle(2, latest: false, scheduler: MainScheduler.instance)
            .mapTo(ViewReactor.Action.loadMore)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map { $0.user }
            .unwrap()
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [userView] in userView.configure(with: $0) })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isFooterAnimating }
            .asDriver(onErrorDriveWith: .never())
            .drive(footerActivityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        let dataSource = RxTableViewSectionedAnimatedDataSource<ViewReactor.State.SectionType>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .fade),
            configureCell: { _, tableView, index, track in
                tableView.dequeueReusableCell(for: index, cellType: TrackTableViewCell.self).then {
                    $0.track = track
                }
            }
        )

        reactor.state
            .map { $0.sections }
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        reactor.state.map { $0.error }
            .unwrap()
            .bind { [unowned self] in self.showError(message: $0) }
            .disposed(by: disposeBag)

        reactor.state.map { $0.isRefreshing }.bind(to: refreshControl.rx.isRefreshing).disposed(by: disposeBag)
        tableView.rx.willDisplayCell.bind { ($0.cell as? TrackTableViewCell)?.loadImage() }.disposed(by: disposeBag)
    }
}

// MARK: - Private
private extension ViewController {
    func showError(message: String) {
        guard presentedViewController == nil else { return }
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert).then {
            $0.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        present(alert, animated: true)
    }
}
