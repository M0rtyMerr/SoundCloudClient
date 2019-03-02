//
//  SoundCloudService.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import RxSwift

protocol UserService {
    func get(id: Int) -> Single<User>
}
