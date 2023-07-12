//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 7/11/23.
//

import Foundation

typealias LoadItemsResult = Result<[FeedItem], Error>

protocol FeedLoader {
    func load(compleation: @escaping (LoadItemsResult) -> Void)
}
