//
//  TestableObserver+elements().swift
//  SoundCloutClientTests
//
//  Created by Anton Nazarov on 04/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import RxTest

extension TestableObserver where ElementType: Equatable {
    var elements: [Element] {
        return self.events.compactMap { $0.value.element }.distinctUntilChanged()
    }
}
