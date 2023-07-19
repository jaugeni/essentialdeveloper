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
                    let json = makeItemsJSON([])
                    client.complete(withStatusCode: code, data: json, at: index)
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
                let invalidJSON = makeItemsJSON([["fake": "invalid JSON"]])
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
                let emptryListJSON = makeItemsJSON([])
                client.complete(withStatusCode: 200, data: emptryListJSON)
            })
    }
    
    func test_load_deliversItemOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageUrl: URL(string: "https://a-url.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageUrl: URL(string: "https://another-url.com")!
        )
        
        let items = [item1.model, item2.model]
        
        expect(
            sut,
            toCompleteWith: .success(items),
            when: {
                let json = makeItemsJSON([item1.json, item2.json])
                client.complete(withStatusCode: 200, data: json)
            })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK - Helpers
    
    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageUrl: URL
    ) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageUrl: imageUrl
        )
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image" : imageUrl.absoluteString,
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader, cliet: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "Instant should have been deallocated. Potential memory leak.",
                file: file,
                line: line
            )
        }
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
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
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
