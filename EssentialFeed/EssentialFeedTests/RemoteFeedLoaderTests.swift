//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Yauheni Ivaniuk on 7/11/23.
//

import XCTest

class ReomoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
    
}

class HTTPClient {
    static var shared = HTTPClient()
            
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    override func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequstDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = ReomoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requstDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = ReomoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
