//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Yauheni Ivaniuk on 7/11/23.
//

import XCTest

class ReomoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
    
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequstDataFromURL() {
        let client = HTTPClient.shared
        _ = ReomoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requstDataFromURL() {
        let client = HTTPClient.shared
        let sut = ReomoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
