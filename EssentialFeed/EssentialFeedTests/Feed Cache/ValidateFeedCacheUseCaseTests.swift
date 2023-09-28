//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Yauheni Ivaniuk on 9/27/23.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreating() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_validateCache_deleteCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.copmleteRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCach_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.copmleteRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_validateCach_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentdate = Date()
        let lessThanSavenDaysOldTimeStamp = fixedCurrentdate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentdate })
        
        sut.validateCache()
        store.copmleteRetrieval(with: feed.local, timestamp: lessThanSavenDaysOldTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func  test_validateCach_deleteSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentdate = Date()
        let savenDaysOldTimeStamp = fixedCurrentdate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentdate })
        
        sut.validateCache()
        store.copmleteRetrieval(with: feed.local, timestamp: savenDaysOldTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCach_deleteOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentdate = Date()
        let moreThanSavenDaysOldTimeStamp = fixedCurrentdate.adding(days: -7).addingTimeInterval(-1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentdate })
        
        sut.validateCache()
        store.copmleteRetrieval(with: feed.local, timestamp: moreThanSavenDaysOldTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCach_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        
        sut = nil
        store.copmleteRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}
