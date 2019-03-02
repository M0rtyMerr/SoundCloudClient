//
//  UserView.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Kingfisher
import Reusable
import UIKit

final class UserView: UIView, NibLoadable {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var fullnameLabel: UILabel!

    func configure(with user: User) {
        avatarImageView.kf.setImage(with: user.avatar)
        fullnameLabel.text = user.fullName
    }
}
