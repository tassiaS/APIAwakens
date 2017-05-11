//
//  SWApiCllient.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 19/01/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import Foundation

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
            return "/api/starships/"
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
            return starships.flatMap { return Starship(JSON: $0) }
        }, completion: completion)
    }
    
    func fetchForVehicle(nextPage: Int, completion: @escaping (APIResult<[Vehicle]>) -> Void) {
        let endpoint = SWAwakens.Vehicle(nextPage: nextPage)
        
        fetch(request: endpoint.request, parse: { (json) -> [Vehicle]? in
            guard let vehicles = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            
            let vehiclesFlatMap = vehicles.flatMap { return Vehicle(JSON: $0) }
            
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
            print(endpoint.request.url?.absoluteString)

            guard let characters = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            return characters.flatMap { return Character(JSON: $0) }
        }, completion: completion)
    }
    
    func fetchForCharacterPlanet(with planetId: String, completion: @escaping (APIResult<Planet>) -> Void) {
        let endpoint = SWAwakens.CharacterPlanet(planetId: planetId)
        
        fetch(request: endpoint.request, parse: { (json) -> Planet? in
            if let planet = Planet(JSON: json) {
                return planet
            } else {
                return nil
            }
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








