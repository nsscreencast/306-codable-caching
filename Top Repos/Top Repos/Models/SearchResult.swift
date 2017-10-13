//
//  SearchResult.swift
//  Top Repos
//
//  Created by Ben Scheirman on 10/11/17.
//  Copyright © 2017 NSScreencast. All rights reserved.
//

import Foundation

struct SearchResult<T : Decodable> : Decodable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [T]
    
    enum CodingKeys : String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}
