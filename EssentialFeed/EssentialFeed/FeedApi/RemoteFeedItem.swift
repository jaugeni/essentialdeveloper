//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 9/13/23.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
