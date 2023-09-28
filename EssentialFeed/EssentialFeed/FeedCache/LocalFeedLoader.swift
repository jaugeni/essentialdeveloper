//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 9/7/23.
//

import Foundation

public final class LocalFeedLoader {
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    private let store: FeedStore
    private let currentDate:  () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return currentDate() < maxCacheAge
    }
}

extension LocalFeedLoader {
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
    public func load(compleation: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return}
            switch result {
            case let .failure(error):
                compleation(.failure(error))
            case let .found(feed, timestamp) where self.validate(timestamp):
                compleation(.success(feed.toModels()))
            case .found, .empty:
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
            case let .found(_, timestamp) where !self.validate(timestamp):
                self.store.deleteCachedFeed { _ in }
            case .empty, .found: break
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
