//
//  TrackTableViewCell.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Kingfisher
import Reusable
import UIKit

final class TrackTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    private lazy var imageProcessor = DownsamplingImageProcessor(size: avatarImageView.frame.size)
        >> RoundCornerImageProcessor(cornerRadius: avatarImageView.layer.cornerRadius)

    override func awakeFromNib() {
        super.awakeFromNib()
        var kf = avatarImageView.kf
        kf.indicatorType = .activity
        avatarImageView.kf = kf
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
    }

    var track: Track? {
        didSet {
            titleLabel.text = track?.title
        }
    }

    func loadImage() {
        avatarImageView.kf.setImage(
            with: track?.artwork,
            placeholder: #imageLiteral(resourceName: "Placeholder"),
            options: [.processor(imageProcessor)]
        )
    }
}
