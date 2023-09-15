//
//  LoadFeedFromCacheUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Yauheni Ivaniuk on 9/14/23.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTest: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreating() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private class FeedStoreSpy: FeedStore {
        
        enum ReceivedMessagges: Equatable {
            case deleteCacheFeed
            case insert([LocalFeedImage], Date)
        }
        
        private(set) var recievedMessages = [ReceivedMessagges]()
        
        private var deletionCompleations = [DeletionCompletion]()
        private var insertionCompleations = [InsertionCompCompletion]()
        
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
    }
    
}
