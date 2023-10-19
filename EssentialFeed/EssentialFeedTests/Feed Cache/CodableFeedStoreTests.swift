//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Yauheni Ivaniuk on 10/18/23.
//

import XCTest
@testable import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrivalCompleation) {
        completion(.empty)
    }

}

class CodableFeedStoreTestsL: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
