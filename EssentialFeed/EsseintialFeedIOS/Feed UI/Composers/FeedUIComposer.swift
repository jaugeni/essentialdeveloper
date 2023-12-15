//
//  FeedUIComposer.swift
//  EsseintialFeedIOS
//
//  Created by Yauheni Ivaniuk on 12/14/23.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refreshControler = FeedRefreshViewController(presenter: presenter)
        let feedController = FeedViewController(refreshController: refreshControler)
        presenter.loadingView = refreshControler
        presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)        
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(
                    viewModel: FeedImageViewModel(
                        model: model,
                        imageLoader: loader,
                        imageTransformer: UIImage.init
                    )
                )
            }
        }
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(feed: [EssentialFeed.FeedImage]) {
        controller?.tableModel = feed.map { model in
            FeedImageCellController(
                viewModel:
                    FeedImageViewModel(
                        model: model,
                        imageLoader: imageLoader,
                        imageTransformer: UIImage.init
                    )
            )
        }
    }
}

// MVVM Version
//public final class FeedUIComposer {
//    private init() {}
//    
//    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
//        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
//        let refreshControler = FeedRefreshViewController(viewModel: feedViewModel)
//        let feedController = FeedViewController(refreshController: refreshControler)
//        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
//        return feedController
//    }
//    
//    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
//        return { [weak controller] feed in
//            controller?.tableModel = feed.map { model in
//                FeedImageCellController(
//                    viewModel: FeedImageViewModel(
//                        model: model,
//                        imageLoader: loader,
//                        imageTransformer: UIImage.init
//                    )
//                )
//            }
//        }
//    }
//}
