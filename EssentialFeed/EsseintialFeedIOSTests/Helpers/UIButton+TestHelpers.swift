//
//  UIButton+TestHelpers.swift
//  EsseintialFeedIOSTests
//
//  Created by Yauheni Ivaniuk on 12/14/23.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
