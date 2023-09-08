//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 9/7/23.
//

import Foundation

public final class LocalFeedLoader {
    public typealias SaveResult = Error?
    
    private let store: FeedStore
    private let currentDate:  () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], compeltion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            
            if let cachDeletionError = error {
                compeltion(cachDeletionError)
            } else {
                self.cache(items, with: compeltion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with compeltion: @escaping (Error?) -> Void) {
        store.insert(items, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return}
            compeltion(error)
        }
    }
}
