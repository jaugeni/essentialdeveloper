//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Yauheni Ivaniuk on 9/14/23.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessagges: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var recievedMessages = [ReceivedMessagges]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrivalCompleations = [RetrivalCompleation]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion (with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccesfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrivalCompleation) {
        retrivalCompleations.append(completion)
        recievedMessages.append(.retrieve)
    }
    
    func copmleteRetrieval(with error: Error, at index: Int = 0) {
        retrivalCompleations[index](.failure(error))
    }
    
    func copmleteRetrievalWithEmptyCache(at index: Int = 0) {
        retrivalCompleations[index](.success(.none))
    }
    
    func copmleteRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrivalCompleations[index](.success(CacheFeed(feed: feed, timestamp: timestamp)))
    }
}
