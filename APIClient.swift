//
//  APIClient.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 18/01/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import Foundation

public let TREnetworkingErrorDomain = "com.treehouse.Stormy.NetwowrkingError"
public let JsonKeyOrElementInvalid: Int = 20
typealias JSON = [String: AnyObject]


enum APIResult<T> {
    case success((resource: T, hasPage: Bool))
    case failure(Error)
}

protocol APIClient {
    var session: URLSession { get }
    var configuration: URLSessionConfiguration { get }
    
    func jsonTask(with request: URLRequest, completion: @escaping (JSON?, HTTPURLResponse?, Error?) -> Void) -> URLSessionDataTask
    func fetch<T>(request: URLRequest, parse: @escaping (JSON) -> T? , completion: @escaping (APIResult<T>) -> Void)
}

extension APIClient {
    func jsonTask(with request: URLRequest, completion: @escaping (JSON?, HTTPURLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let HTTPResponse = response as? HTTPURLResponse else {
                completion(nil, nil, error)
                return
            }
            
            if data == nil {
                if let error = error {
                    completion(nil, HTTPResponse, error)
                }
            }else {
                switch HTTPResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : AnyObject]
                        completion(json as JSON?, nil, nil)
                    } catch {
                        print("json error: \(error.localizedDescription)")
                    }
                default:
                    print("Received HTTP response: \(HTTPResponse.statusCode), which was not handled, \(request.url)")
                }
            }
        }
        return task
    }

    func fetch<T>(request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void) {
        var hasNextPage = true
        let task = jsonTask(with: request) { (json, reponse, error) in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(APIResult.failure(error))
                    }
                    return
                }
                
                if let result = parse(json) {
                    if (json["next"] as? String) != nil {
                        completion(APIResult.success((result,hasNextPage)))
                    } else {
                        hasNextPage = false
                        completion(APIResult.success((result,hasNextPage)))
                    }
                } else {
                    let error = NSError(domain: TREnetworkingErrorDomain, code: JsonKeyOrElementInvalid, userInfo: nil)
                    completion(APIResult.failure(error))
                }
            }
        }
        task.resume()
    }
}














