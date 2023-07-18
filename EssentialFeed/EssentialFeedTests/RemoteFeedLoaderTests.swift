//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Yauheni Ivaniuk on 7/11/23.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequstDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requstsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requstsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loading_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(
            sut,
            toCompleteWith: .failure(.connectivity),
            when: {
                let clientError = NSError(domain: "Test", code: 0)
                client.complete(with: clientError)
            }
        )
    }
    
    func test_loading_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let sampels = [199, 201, 300, 400, 500]
        
        sampels.enumerated().forEach { index, code in
            expect(
                sut,
                toCompleteWith: .failure(.invalidData),
                when: {
                    client.complete(withStatusCode: code, at: index)
                }
            )
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(
            sut,
            toCompleteWith: .failure(.invalidData),
            when: {
                let invalidJSON = Data(bytes: "ivalid json".utf8)
                client.complete(withStatusCode: 200, data: invalidJSON)
            }
        )
    }
    
    func test_load_deliversNoItemesOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(
            sut,
            toCompleteWith: .success([]),
            when: {
                let emptryListJSON = Data(bytes: "{\"items\": []}".utf8)
                client.complete(withStatusCode: 200, data: emptryListJSON)
            })
    }
    
    func test_load_deliversItemOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageUrl: URL(string: "https://a-url.com")!
        )
        
        let item1JSON = [
            "id" : item1.id.uuidString,
            "image" : item1.imageUrl.absoluteString
        ]
        
        let item2 = FeedItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageUrl: URL(string: "https://another-url.com")!
        )
        
        let item2JSON = [
            "id" : item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image" : item2.imageUrl.absoluteString,
        ]
        
        let itemJSON = [
            "items": [item1JSON, item2JSON]
        ]
        
        expect(
            sut,
            toCompleteWith: .success([item1, item2]),
            when: {
                let json = try! JSONSerialization.data(withJSONObject: itemJSON)
                client.complete(withStatusCode: 200, data: json)
            })
    }
    
    // MARK - Helpers
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith result: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var captureResults = [RemoteFeedLoader.Result]()
        sut.load { captureResults.append($0) }
        
        action()
        
        XCTAssertEqual(captureResults, [result], file: file, line: line)
    }
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!
    ) -> (sut: RemoteFeedLoader, cliet: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
