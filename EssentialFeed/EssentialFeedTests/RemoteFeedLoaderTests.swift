//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Yauheni Ivaniuk on 7/11/23.
//

import XCTest

class ReomoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequstDataFromURL() {
        let client = HTTPClient()
        let sut = ReomoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }

}
