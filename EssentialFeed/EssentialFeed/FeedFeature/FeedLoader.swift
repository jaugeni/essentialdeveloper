//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 7/11/23.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedItem], Error>

public protocol FeedLoader {
    func load(compleation: @escaping (LoadFeedResult) -> Void)
}
