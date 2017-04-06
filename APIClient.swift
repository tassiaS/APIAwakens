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

protocol JSONDecodable {
    init?(JSON: [String: AnyObject])
}

//Used for character, vehicle and starship
protocol Measurable: JSONDecodable{
    var size: Double { get }
}

//Used only for vehicles and starships
protocol TransportCraft: Measurable {
    var name: String { get }
    var make: String { get }
    var cost: Double { get }
    var swClass: String { get }
    var crew: String { get }
    var capacity: Double { get }
}

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: Int]? { get }
}

extension Endpoint {
    var queryItems: [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
            }
        }
        return queryItems
    }
    
    var request: URLRequest {
        let components = NSURLComponents(string: baseURL)!
        components.path = path
        components.queryItems = queryItems // the URL is percent encoded here
        
        let url = components.url!
        return URLRequest(url: url)
    }
}

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
                        //print(json)
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














