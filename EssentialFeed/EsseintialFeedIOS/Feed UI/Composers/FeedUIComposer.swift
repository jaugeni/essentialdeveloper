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
        let refreshControler = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshControler)
        refreshControler.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map{ model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        return feedController
    }
}
