//
//  UIControl+TestHelpers.swift
//  EsseintialFeedIOSTests
//
//  Created by Yauheni Ivaniuk on 12/14/23.
//


import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
