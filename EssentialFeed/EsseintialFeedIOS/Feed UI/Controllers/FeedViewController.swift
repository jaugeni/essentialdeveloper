//
//  FeedViewController.swift
//  EsseintialFeedIOS
//
//  Created by Yauheni Ivaniuk on 12/14/23.
//

import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    public var refreshControler: FeedRefreshViewController?
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var cellControllers = [IndexPath: FeedImageCellController]()
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.refreshControler = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshControler?.view
        refreshControler?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }
        tableView.prefetchDataSource = self
        refreshControler?.refresh()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        refreshControl?.beginRefreshing()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        startTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            startTask(forRowAt: indexPath)
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let cellModel = tableModel[indexPath.row]
        let cellController = FeedImageCellController(model: cellModel, imageLoader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
    private func startTask(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).preload()
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
