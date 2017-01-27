//
//  SWApiCllient.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 19/01/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import Foundation

final class SWApiClient: APIClient {
    
    var configuration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)
    }()
    
    init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    
    func fetchForStarship(nextPage: Int, completion: @escaping (APIResult<Starship>) -> Void) {
        var components = URLComponents(string: "http://swapi.co")!
        var queryItens = [URLQueryItem]()
        queryItens.append(URLQueryItem(name: "page", value: String(nextPage)))
        components.path = "/api/starships/"
        components.queryItems = queryItens
        let url = components.url!
       
        let request = URLRequest(url: url)
        

        fetch(request: request, parse: { (json) -> [Starship]? in
            guard let starships = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            return starships.flatMap { return Starship(JSON: $0) }
        }, completion: completion)
    }
}








