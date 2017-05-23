//
//  SWApiCllient.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 19/01/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import Foundation

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

enum SWAwakens: Endpoint {
    case Vehicle(nextPage: Int)
    case Character(nextPage: Int)
    case CharacterPlanet(planetId: String)
    case CharacterStarship(starshipId: String)
    case CharacterVehicle(VehicleId: String)
    case Starship(nextPage: Int)
    
    var baseURL: String {
        return "http://swapi.co"
    }
    var path: String {
        switch self {
        case .Starship:
            return "/api/starship/"
        case . Character:
            return  "/api/people/"
        case .CharacterPlanet(let planetId):
            return "/api/planets/\(planetId)/"
        case .CharacterVehicle(let vehicleId):
            return "/api/vehicles/\(vehicleId)/"
        case .CharacterStarship(let starshipId):
            return "/api/starships/\(starshipId)/"
        case .Vehicle:
            return "/api/vehicles/"
        }
    }
    var parameters: [String : Int]? {
        var parameters = [String : Int]()
        switch self {
        case .Starship(let nextPage), .Character(let nextPage), .Vehicle(let nextPage):
            parameters["page"] = nextPage
            return parameters
        default: return nil
        }
    }
}

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
        let endpoint = SWAwakens.Starship(nextPage: nextPage)
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Starship]? in
            guard let starships = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            return starships.flatMap {
                do {
                    return try Starship(JSON: $0)
                } catch (let error){
                    print(error)
                }
                return nil
            }
        }, completion: completion)
    }
    
    func fetchForVehicle(nextPage: Int, completion: @escaping (APIResult<[Vehicle]>) -> Void) {
        let endpoint = SWAwakens.Vehicle(nextPage: nextPage)
        
        fetch(request: endpoint.request, parse: { (json) -> [Vehicle]? in
            guard let vehicles = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            
            let vehiclesFlatMap: [Vehicle] = vehicles.flatMap {
                do {
                   return try Vehicle(JSON: $0)
                } catch (let error){
                    print(error)
                }
                return nil
            }
            
            if vehiclesFlatMap.isEmpty {
                return nil
            } else {
                return vehiclesFlatMap
            }
        }, completion: completion)
    }
    
    func fetchForCharacter(nextPage: Int, completion: @escaping (APIResult<[Character]>) -> Void) {
        let endpoint = SWAwakens.Character(nextPage: nextPage)
        
        
        fetch(request: endpoint.request, parse: { (json) -> [Character]? in
            
            guard let characters = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            return characters.flatMap {
                do {
                    return try Character(JSON: $0)
                } catch (let error){
                    print(error)
                }
                return nil
            }
        }, completion: completion)
    }
    
    func fetchForCharacterPlanet(with planetId: String, completion: @escaping (APIResult<Planet>) -> Void) {
        let endpoint = SWAwakens.CharacterPlanet(planetId: planetId)
        
        fetch(request: endpoint.request, parse: { (json) -> Planet? in
            do {
                return try Planet(JSON: json)
            } catch (let error){
                print(error)
            }
            return nil
        }, completion: completion)
    }
    
    func fetchForCharacterVehicle(with vehicleId: String, completion: @escaping (APIResult<Vehicle>)-> Void) {
            let endpoint = SWAwakens.CharacterVehicle(VehicleId: vehicleId)
            fetch(request: endpoint.request, parse: { (json) -> Vehicle? in
                if let vehicle = Vehicle(jsonName: json) {
                    return vehicle
                } else {
                    return nil
                }
            }, completion: completion)
    }
    
    func fetchForCharacterStarship(with starshipId: String, completion: @escaping (APIResult<Starship>)-> Void) {
        let endpoint = SWAwakens.CharacterStarship(starshipId: starshipId)
        fetch(request: endpoint.request, parse: { (json) -> Starship? in
            if let starship = Starship(jsonName: json) {
                return starship
            } else {
                return nil
            }
        }, completion: completion)
    }
}








