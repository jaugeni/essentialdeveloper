//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 9/7/23.
//

import Foundation

public typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Result<CacheFeed?, Error>
    typealias RetrivalCompleation = (RetrievalResult) -> Void


    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrivalCompleation)
}
