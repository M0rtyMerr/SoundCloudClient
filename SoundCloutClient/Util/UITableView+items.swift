//
//  UITableView+items.swift
//  SoundCloutClient
//
//  Created by Anton Nazarov on 02/03/2019.
//  Copyright © 2019 Anton Nazarov. All rights reserved.
//

import Reusable
import RxSwift

extension Reactive where Base: UITableView {
    func items<S: Sequence, Cell: UITableViewCell & Reusable, O: ObservableType>(_ cellType: Cell.Type)
        -> (_ source: O)
        -> (_ configureCell: @escaping (Int, S.Iterator.Element, Cell) -> Void)
        -> Disposable where O.E == S {
            return items(cellIdentifier: cellType.reuseIdentifier, cellType: cellType)
    }
}
