//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 9/7/23.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate:  () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
    public func save(_ feed: [FeedImage], compeltion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            
            if let cachDeletionError = error {
                compeltion(cachDeletionError)
            } else {
                self.cache(feed, with: compeltion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with compeltion: @escaping (Error?) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return}
            compeltion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func load(compleation: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return}
            switch result {
            case let .failure(error):
                compleation(.failure(error))
            case let .success(.found(feed, timestamp)) where FeedCachepolicy.validate(timestamp, against: self.currentDate()):
                compleation(.success(feed.toModels()))
            case .success:
                compleation(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .success(.found(_, timestamp)) where !FeedCachepolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
            case .success: break
            }
        }
       
    }
    

}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url
        ) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map { FeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url
        ) }
    }
}
