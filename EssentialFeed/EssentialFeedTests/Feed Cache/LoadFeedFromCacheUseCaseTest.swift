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
        
        sut.load()
        
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
