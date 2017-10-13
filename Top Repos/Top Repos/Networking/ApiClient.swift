//
//  APIClient.swift
//  Top Repos
//
//  Created by Ben Scheirman on 10/11/17.
//  Copyright © 2017 NSScreencast. All rights reserved.
//

import Foundation

enum ApiResult<T> {
    case success(T)
    case error(Error)
}

typealias ApiResponseBlock<T> = (ApiResult<T>) -> Void

class ApiClient {
    
    enum RequestError : Error {
        case genericError
        case parsingError(Error)
    }
    
    let session: URLSession
    let baseURL: URL
    
    init(session: URLSession, baseURL: URL) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func fetch<R : Decodable>(resource: Resource, completion: @escaping ApiResponseBlock<R>) {
        
        let request = buildRequest(for: resource)
        let dispatchCompletion = dispatchMain(completion)
        
        print("HTTP GET: \(request.url!)")
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            sleep(1)
            if let e = error {
                dispatchCompletion(.error(e))
            } else {
                let http = response as! HTTPURLResponse
                print("<-- HTTP \(http.statusCode)")
                switch http.statusCode {
                case 200:
                    let result: ApiResult<R> = self.handleResourceData(data!, resource: resource)
                    dispatchCompletion(result)
                default:
                    if let data = data, let body = String(data: data, encoding: .utf8) {
                        print(body)
                    }
                    dispatchCompletion(.error(RequestError.genericError))
                }
            }
        }
        
        task.resume()
    }
    
    private func handleResourceData<R : Decodable>(_ data: Data, resource: Resource) -> ApiResult<R> {
        do {
            let object: R = try resource.parse(data: data)
            return .success(object)
        } catch let e {
            let wrappedError = RequestError.parsingError(e)
            return .error(wrappedError)
        }
    }
    
    private func buildRequest(for resource: Resource) -> URLRequest {
        let url = buildURL(for: resource)
        
        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        
        return request
    }
    
    private func buildURL(for resource: Resource) -> URL {
        var url = baseURL.appendingPathComponent(resource.path)
        if let queryParams = resource.queryParams, !queryParams.keys.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.queryItems = queryParams.map { URLQueryItem(name: $0.0, value: $0.1) }
            url = components.url!
        }
        return url
    }
    
    private func dispatchMain<T>(_ completion: @escaping ApiResponseBlock<T>) -> ApiResponseBlock<T> {
        return { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

