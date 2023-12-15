//
//  FakeRefreshController.swift
//  EsseintialFeedIOSTests
//
//  Created by Yauheni Ivaniuk on 12/14/23.
//

import UIKit

class FakeRefreshController: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
