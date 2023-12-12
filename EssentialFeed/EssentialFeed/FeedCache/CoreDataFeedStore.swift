//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 12/12/23.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    public init() {}
    
    public func retrieve(completion: @escaping RetrivalCompleation) {
        completion(.empty)
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompCompletion) {
        
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }
}
