//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Yauheni Ivaniuk on 9/13/23.
//

import Foundation

 struct RemoteFeedItem: Decodable {
     let id: UUID
     let description: String?
     let location: String?
     let image: URL
}
