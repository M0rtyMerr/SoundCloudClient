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
import RxSwift
import Then
import UIKit

class ViewController: UIViewController, StoryboardBased, StoryboardView {
    @IBOutlet private var tableView: UITableView!
    private lazy var userView = UserView.loadFromNib()
    private lazy var footerActivityIndicator = UIActivityIndicatorView(style: .gray).then {
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

        reactor.state.map { $0.tracks }
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [unowned self] _ in
                self.footerActivityIndicator.stopAnimating()
                self.tableView.refreshControl?.endRefreshing()
             })
            .drive(tableView.rx.items(TrackTableViewCell.self)) { _, track, cell in
                cell.configure(with: track)
            }
            .disposed(by: disposeBag)
    }

//    var player:AVPlayer?
//    var playerItem:AVPlayerItem?
//    var playButton:UIButton?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        let url = URL(string: "https://api.soundcloud.com/tracks/306367098/stream?allow_redirects=true&client_id=c23089b7e88643b5b839c4b8609fce3b")
//        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
//        player = AVPlayer(playerItem: playerItem)
//
//        let playerLayer=AVPlayerLayer(player: player!)
//        playerLayer.frame=CGRect(x:0, y:0, width:10, height:50)
//        self.view.layer.addSublayer(playerLayer)
//
//        playButton = UIButton(type: UIButton.ButtonType.system) as UIButton
//        let xPostion:CGFloat = 50
//        let yPostion:CGFloat = 100
//        let buttonWidth:CGFloat = 150
//        let buttonHeight:CGFloat = 45
//
//        playButton!.frame = CGRect(x: xPostion, y: yPostion, width: buttonWidth, height: buttonHeight)
//        playButton!.backgroundColor = UIColor.lightGray
//        playButton!.setTitle("Play", for: UIControl.State.normal)
//        playButton!.tintColor = UIColor.black
//        playButton!.addTarget(self, action: #selector(ViewController.playButtonTapped(_:)), for: .touchUpInside)
//
//        self.view.addSubview(playButton!)
//    }
//
//    @objc func playButtonTapped(_ sender:UIButton)
//    {
//        if player?.rate == 0
//        {
//            player!.play()
//            //playButton!.setImage(UIImage(named: "player_control_pause_50px.png"), forState: UIControlState.Normal)
//            playButton!.setTitle("Pause", for: UIControl.State.normal)
//        } else {
//            player!.pause()
//            //playButton!.setImage(UIImage(named: "player_control_play_50px.png"), forState: UIControlState.Normal)
//            playButton!.setTitle("Play", for: UIControl.State.normal)
//        }
//    }

}
