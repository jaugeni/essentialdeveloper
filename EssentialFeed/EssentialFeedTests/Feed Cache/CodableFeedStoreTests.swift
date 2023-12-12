//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Yauheni Ivaniuk on 10/18/23.
//

import XCTest
@testable import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreSate()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: makeSUT())
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: makeSUT())
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: makeSUT())
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: makeSUT())
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        assertThatInsertDeliversNoErrorOnEmptyCache(on: makeSUT())
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: makeSUT())
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: makeSUT())
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)

        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)

        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: makeSUT())
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: makeSUT())
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: makeSUT())
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: makeSUT())
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        assertThatSideEffectsRunSerially(on: makeSUT())
    }
    
    // - MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func setupEmptyStoreSate() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
