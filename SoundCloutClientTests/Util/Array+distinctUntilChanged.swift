//
//  Array+distinctUntilChanged.swift
//  SoundCloutClientTests
//
//  Created by Anton Nazarov on 04/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

extension Array where Element: Equatable {
    func distinctUntilChanged() -> [Element] {
        var newArray = [Element]()
        self.forEach {
            guard let last = newArray.last else {
                newArray.append($0)
                return
            }
            if $0 != last {
                newArray.append($0)
            }
        }
        return newArray
    }
}
