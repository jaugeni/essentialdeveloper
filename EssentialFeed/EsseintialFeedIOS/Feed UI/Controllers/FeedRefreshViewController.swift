//
//  FeedRefreshViewController.swift
//  EsseintialFeedIOS
//
//  Created by Yauheni Ivaniuk on 12/14/23.
//

import UIKit

final public class FeedRefreshViewController: NSObject, FeedLoadingView {
    
     public lazy var view = loadingView()
    
    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    @objc func refresh() {
        presenter.loadFeed()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadingView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

// MVVMV Version
//final public class FeedRefreshViewController: NSObject {
//     public lazy var view = binded(UIRefreshControl())
//    
//    private let viewModel: FeedViewModel
//    
//    init(viewModel: FeedViewModel) {
//        self.viewModel = viewModel
//    }
//    
//    @objc func refresh() {
//        viewModel.loadFeed()
//    }
//    
//    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
//        
//        viewModel.onLoadingStateChange = { [weak self] isLoading in
//            if isLoading {
//                self?.view.beginRefreshing()
//            } else {
//                self?.view.endRefreshing()
//            }
//        }
//        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        return view
//    }
//}
