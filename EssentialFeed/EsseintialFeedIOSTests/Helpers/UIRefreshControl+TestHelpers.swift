//
//  UIRefreshControl+TestHelpers.swift
//  EsseintialFeedIOSTests
//
//  Created by Yauheni Ivaniuk on 12/14/23.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
