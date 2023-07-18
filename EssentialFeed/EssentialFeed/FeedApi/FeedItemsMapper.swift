//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 7/18/23.
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(
                id: id,
                description: description,
                location: location,
                imageUrl: image
            )
        }
    }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try JSONDecoder()
            .decode(Root.self, from: data)
            .items.map { $0 .item }
    }
}
