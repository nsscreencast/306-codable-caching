//
//  OpenLibraryClient.swift
//  Top Repos
//
//  Created by Ben Scheirman on 10/11/17.
//  Copyright © 2017 NSScreencast. All rights reserved.
//

import Foundation

class GitHubClient : ApiClient {
    
    let reposStore: LocalJSONStore<[Repository]> = LocalJSONStore(storageType: .cache, filename: "repos.json")
    
    static var shared: GitHubClient = {
        var config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept" : "application/json"
        ]
        let session = URLSession(configuration: config)
        let baseURL = URL(string: "https://api.github.com")!
        return GitHubClient(session: session, baseURL: baseURL)
    }()
    
    func searchRepositories(term: String, completion: @escaping ApiResponseBlock<[Repository]>) {
        
        if let repos = reposStore.storedValue {
            completion(.success(repos))
        }
        
        let resource = Resource(path: "/search/repositories", queryParams: [
            "q": term,
            "sort": "stars"
        ])
        
        fetch(resource: resource) { (result: ApiResult<SearchResult<Repository>>) in
            switch result {
            case .success(let searchResult):
                self.reposStore.save(searchResult.items)
                completion(.success(searchResult.items))
            case .error(let e):
                completion(.error(e))
            }
        }
    }
    
    func fetchContributors(repository: Repository, completion: @escaping ApiResponseBlock<[User]>) {
        let path = repository.url.path.appending("/contributors")
        let resource = Resource(path: path, queryParams: [:])
        fetch(resource: resource, completion: completion)
    }
    
    
}
