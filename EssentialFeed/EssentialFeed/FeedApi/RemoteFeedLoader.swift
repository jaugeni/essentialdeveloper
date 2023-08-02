//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 7/11/23.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(
        url: URL,
        client: HTTPClient
    ) {
        self.client = client
        self.url = url
    }
    
    public func load(compleation: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else {
                return
                
            }
            
            switch result {
            case let .success(data, response):
                compleation(FeedItemsMapper.map(data, from: response))
            case .failure:
                compleation(.failure(Error.connectivity))
            }
        }
    }
}
