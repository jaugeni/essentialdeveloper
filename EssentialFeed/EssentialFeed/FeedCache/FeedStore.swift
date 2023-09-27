//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 9/7/23.
//

import Foundation

public enum RetrieveCachedFeedResut {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompCompletion = (Error?) -> Void
    typealias RetrivalCompleation = (RetrieveCachedFeedResut) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompCompletion)
    func retrieve(completion: @escaping RetrivalCompleation)
}
