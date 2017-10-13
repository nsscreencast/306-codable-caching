//
//  User.swift
//  Top Repos
//
//  Created by Ben Scheirman on 10/11/17.
//  Copyright © 2017 NSScreencast. All rights reserved.
//

import Foundation

struct User : Codable {
    let login: String
    let id: Int
    let avatarUrl: URL
    let type: String
    
    enum CodingKeys : String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
        case type
    }
}
