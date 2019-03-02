//
//  Util.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Foundation

enum Util {
    static func json(named name: String) -> Data {
        guard let filePath = Bundle.main.path(forResource: name, ofType: "json") else {
            // swiftlint:disable:next force_unwrapping
            return "".data(using: String.Encoding.utf8)!
        }
        // swiftlint:disable:next force_try
        return try! Data(contentsOf: URL(fileURLWithPath: filePath))
    }
}
