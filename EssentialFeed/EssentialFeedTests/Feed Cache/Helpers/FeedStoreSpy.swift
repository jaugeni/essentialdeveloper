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
    
    private var deletionCompleations = [DeletionCompletion]()
    private var insertionCompleations = [InsertionCompCompletion]()
    private var retrivalCompleations = [RetrivalCompleation]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompleations.append(completion)
        recievedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompleations[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompleations[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompCompletion) {
        insertionCompleations.append(completion)
        recievedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion (with error: Error, at index: Int = 0) {
        insertionCompleations[index](error)
    }
    
    func completeInsertionSuccesfully(at index: Int = 0) {
        insertionCompleations[index](nil)
    }
    
    func retrieve(completion: @escaping RetrivalCompleation) {
        retrivalCompleations.append(completion)
        recievedMessages.append(.retrieve)
    }
    
    func copmleteRetrieval(with error: Error, at index: Int = 0) {
        retrivalCompleations[index](error)
    }
    
    func copmleteRetrievalWithEmptyCache(at index: Int = 0) {
        retrivalCompleations[index](nil)
    }
}
