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
    
    
    func fetchForStarship(nextPage: Int, completion: @escaping (APIResult<[Starship]>) -> Void) {
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
    
    func fetchForVehicle(nextPage: Int, completion: @escaping (APIResult<[Vehicle]>) -> Void) {
        var components = URLComponents(string: "http://swapi.co")!
        var queryItens = [URLQueryItem]()
        queryItens.append(URLQueryItem(name: "page", value: String(nextPage)))
        components.path = "/api/vehicles/"
        components.queryItems = queryItens
        let url = components.url!
        
        let request = URLRequest(url: url)
        
        
        fetch(request: request, parse: { (json) -> [Vehicle]? in
            guard let vehicles = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            return vehicles.flatMap { return Vehicle(JSON: $0) }
        }, completion: completion)
    }
    
    func fetchForCharacter(nextPage: Int, completion: @escaping (APIResult<[Character]>) -> Void) {
        var components = URLComponents(string: "http://swapi.co")!
        var queryItens = [URLQueryItem]()
        queryItens.append(URLQueryItem(name: "page", value: String(nextPage)))
        components.path = "/api/people/"
        components.queryItems = queryItens
        let url = components.url!
        
        let request = URLRequest(url: url)
        
        
        fetch(request: request, parse: { (json) -> [Character]? in
            guard let characters = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            return characters.flatMap { return Character(JSON: $0) }
        }, completion: completion)
    }
    
    func fetchForPlanet(with id: String, completion: @escaping (APIResult<Planet>) -> Void) {
        var components = URLComponents(string: "http://swapi.co")
        components?.path = "/api/planets/\(id)\("/")"
        let url = components?.url
        
        let request = URLRequest(url: url!)
 
        fetch(request: request, parse: { (json) -> Planet? in
            if let planet = Planet(JSON: json) {
                return planet
            } else {
                return nil
            }
        }, completion: completion)
    }


}








