//
//  Resource.swift
//  Top Repos
//
//  Created by Ben Scheirman on 10/11/17.
//  Copyright © 2017 NSScreencast. All rights reserved.
//

import Foundation

struct Resource {
    
    enum HTTPMethod : String {
        case get
    }
    
    let path: String
    let method: HTTPMethod
    let queryParams: [String: String]?
    
    func parse<T : Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

extension Resource {
    init(path: String) {
        self.init(path: path, method: .get, queryParams: nil)
    }
    
    init(path: String, queryParams: [String : String]) {
        self.init(path: path, method: .get, queryParams: queryParams)
    }
}
