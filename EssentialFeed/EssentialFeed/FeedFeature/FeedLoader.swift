//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 7/11/23.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(compleation: @escaping (LoadFeedResult<Error>) -> Void)
}
