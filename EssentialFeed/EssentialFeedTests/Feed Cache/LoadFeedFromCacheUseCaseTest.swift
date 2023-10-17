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
    
    func test_load_requestsCacheRetrievel() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_failOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError), when:  {
            store.copmleteRetrieval(with: retrievalError)
        })
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when:  {
            store.copmleteRetrievalWithEmptyCache()
        })
    }
    
    func test_load_deliversCachedImagesOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentdate = Date()
        let nonExpiredTimestamp = fixedCurrentdate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentdate })
        
        expect(sut, toCompleteWith: .success(feed.models), when:  {
            store.copmleteRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_load_deliversNoImagesOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentdate = Date()
        let expirationTimestamp = fixedCurrentdate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentdate })
        
        expect(sut, toCompleteWith: .success([]), when:  {
            store.copmleteRetrieval(with: feed.local, timestamp: expirationTimestamp)
        })
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentdate = Date()
        let expiredTimestamp = fixedCurrentdate.minusFeedCacheMaxAge().adding(days: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentdate })
        
        expect(sut, toCompleteWith: .success([]), when:  {
            store.copmleteRetrieval(with: feed.local, timestamp: expiredTimestamp)
        })
    }
    
    func test_load_hasNoSideEffectOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.copmleteRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.copmleteRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnNonExpiredCacheCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentdate = Date()
        let nonExpiredTimestamp = fixedCurrentdate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { nonExpiredTimestamp })
        
        sut.load { _ in }
        store.copmleteRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func  test_load_hasNoSideEffectOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentdate = Date()
        let expirationTimestamp = fixedCurrentdate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentdate })
        
        sut.load { _ in }
        store.copmleteRetrieval(with: feed.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentdate = Date()
        let expiredTimestamp = fixedCurrentdate.minusFeedCacheMaxAge().addingTimeInterval(-1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentdate })
        
        sut.load { _ in }
        store.copmleteRetrieval(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.LoadResult]()
        sut?.load { receivedResults.append($0) }
        
        sut = nil
        store.copmleteRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}

