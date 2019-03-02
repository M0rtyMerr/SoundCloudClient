//
//  TrackTableViewCell.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Reusable
import UIKit

final class TrackTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
    }

    func configure(with track: Track) {
        avatarImageView.kf.setImage(with: track.artwork)
        titleLabel.text = track.title
    }
}
