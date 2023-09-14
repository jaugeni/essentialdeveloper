//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 9/7/23.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompCompletion)
}


public struct LocalFeedItem: Equatable {
   public let id: UUID
   public let description: String?
   public let location: String?
   public let imageUrl: URL
    
    public init(
        id: UUID,
        description: String?,
        location: String?,
        imageUrl: URL
    ) {
        self.id = id
        self.description = description
        self.location = location
        self.imageUrl = imageUrl
    }
}
