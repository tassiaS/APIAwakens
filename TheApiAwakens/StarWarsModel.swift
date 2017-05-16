//
//  SWModel.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 19/01/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import Foundation

protocol JSONDecodable {
    init?(JSON: [String: AnyObject]) throws
}

//Used for character, vehicle and starship
protocol Measurable: JSONDecodable{
    var size: Double { get }
}

enum ErrorApi : Error {
    case jsonInvalidKeyOrElement(String)
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

enum ResourceType: String {
    case character
    case vehicle
    case starship
    case none
    
    static func getType(with imageTag: Int ) -> ResourceType? {
        switch imageTag {
        case 0:
            return .character
        case 1:
            return .vehicle
        case 2:
            return .starship
        default:
            return nil
        }
    }
}

struct Vehicle: TransportCraft {
    var name: String
    var make: String
    var cost: Double
    var size: Double
    var swClass: String
    var crew: String
    var capacity: Double
    
    init?(JSON: [String : AnyObject]) throws {
        
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let make = JSON["manufacturer"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -manufacturer-")
        }
        guard let cost = JSON["cost_in_credits"] as? String, let costInCredits = Double(cost) else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -cost_in_credits-")
        }
        guard let size = JSON["length"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -length-")
        }
        guard let swClass = JSON["vehicle_class"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -vehicle_class-")
        }
        guard let crew = JSON["crew"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -crew-")
        }
        guard let capacity = JSON["cargo_capacity"] as? String, let cargoCapacity = Double(capacity) else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -cargo_capacity-")
        }
        
        self.name = name
        self.make = make
        self.cost = costInCredits
        self.swClass = swClass
        self.crew = crew
        self.capacity = cargoCapacity
        
        //doubleValue converts a string to Double. Cant use Double() because the SWapi returns values both with "." and "," Values with "," are not converted to Double.
        self.size = size.doubleValue
    }
    
    // Used to initiate a Character's Vehicle that needs only a name
     init?(jsonName: [String : AnyObject]) {
        guard let name = jsonName["name"] as? String else {
            return nil
        }
        self.name = name
        self.make = ""
        self.cost = 0.0
        self.swClass = ""
        self.crew = ""
        self.capacity = 0.0
        self.size = 0.0
    }
}

struct Starship: TransportCraft {
    var name: String
    var make: String
    var cost: Double
    var size: Double
    var swClass: String
    var crew: String
    var capacity: Double
    
    init?(JSON: [String : AnyObject]) throws {
        
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let make = JSON["manufacturer"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -manufacturer-")
        }
        guard let cost = JSON["cost_in_credits"] as? String, let costInCredits = Double(cost) else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -cost_in_credits-")
        }
        guard let size = JSON["length"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -length-")
        }
        guard let swClass = JSON["starship_class"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -starship_class-")
        }
        guard let crew = JSON["crew"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -crew-")
        }
        guard let capacity = JSON["cargo_capacity"] as? String, let cargoCapacity = Double(capacity) else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -cargo_capacity-")
        }
        
        self.name = name
        self.make = make
        self.cost = costInCredits
        self.swClass = swClass
        self.crew = crew
        self.capacity = cargoCapacity

        self.size = size.doubleValue

    }
    
    // Used to initiate a Character's Starship that needs only a name
    init?(jsonName: [String : AnyObject]) {
        guard let name = jsonName["name"] as? String else {
            return nil
        }
        self.name = name
        self.make = ""
        self.cost = 0.0
        self.swClass = ""
        self.crew = ""
        self.capacity = 0.0
        self.size = 0.0
    }
}

struct Character: Measurable {
    var name: String
    var born: String
    var size: Double
    var eyes: String
    var hair: String
    var homeworldID: String
    var vehiclesID = [String]()
    var starshipsID = [String]()
    
    init?(JSON: [String : AnyObject]) throws {
        
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let born = JSON["birth_year"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -birth_year-")
        }
        guard let size = JSON["height"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -height-")        }
        guard let eyes = JSON["eye_color"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -eye_color-")
        }
        guard let hair = JSON["hair_color"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -hair_color-")        }
        guard let homeworldEndPoint = JSON["homeworld"] else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -homeworld-")
        }
        guard let vehicleEndPoints = JSON["vehicles"] as? [String] else {
           throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -vehicles-")
        }
        guard let starshipEndpoints = JSON["starships"] as? [String] else {
           throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -starships-")
        }
        
        self.name = name
        self.born = born
        self.eyes = eyes
        self.hair = hair
        self.homeworldID = homeworldEndPoint.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        for vehicleEndPoint in vehicleEndPoints {
            vehiclesID.append(vehicleEndPoint.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
        }
        
        for starshipEndpoint in starshipEndpoints {
            starshipsID.append(starshipEndpoint.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
        }
        
        //let sizeFormatted = String(format:"%.2f", size.doubleValue)
        self.size = size.doubleValue
    }
}

struct Planet: JSONDecodable {
    let name: String
    let id: String
    
    init?(JSON: [String : AnyObject]) throws {
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let url = JSON["url"] else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -url-")
        }
        
        self.name = name
        self.id = url.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}

// returns a double for Strings with both "." and ","
extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
}

extension Double {
    // If the decimal is 0 than return an Int
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.02f", self)
    }
}

