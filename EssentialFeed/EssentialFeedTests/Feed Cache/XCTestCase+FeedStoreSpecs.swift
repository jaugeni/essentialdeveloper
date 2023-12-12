//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Yauheni Ivaniuk on 12/12/23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(
        _ sut: FeedStore,
        toRetrieveTwice expectedResult: RetrieveCachedFeedResut,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(
        _ sut: FeedStore,
        toRetrieve expectedResult: RetrieveCachedFeedResut,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                break
                
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    func insert(
        _ cache: (feed: [LocalFeedImage], timestemp: Date),
        to sut: FeedStore) -> Error?
    {
        let exp = expectation(description: "Wait for cache inserted")
        var insertedError: Error?
        
        sut.insert(cache.feed, timestamp: cache.timestemp) { receivedInsertionError in
            insertedError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertedError
    }
    
    @discardableResult
    func deleteCache(
        from sut: FeedStore) -> Error?
    {
        let exp = expectation(description: "Wait for cache deleted")
        var deletedError: Error?
        
        sut.deleteCachedFeed { receivedDeletedError in
            deletedError = receivedDeletedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        return deletedError
    }
}
