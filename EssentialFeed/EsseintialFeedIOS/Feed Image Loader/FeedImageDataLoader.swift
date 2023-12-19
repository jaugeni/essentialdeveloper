//
//  FeedImageDataLoader.swift
//  EsseintialFeedIOS
//
//  Created by Yauheni Ivaniuk on 12/14/23.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
