//
//  SWModel.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 19/01/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import Foundation

enum ResourceType {
    case character
    case vehicle
    case starship
    case none
}

struct Resource {
    static func getType(with imageTag: Int) -> ResourceType? {
        let tagValue = String(imageTag)
        
        switch tagValue {
        case "0":
            return .character
        case "1":
            return .vehicle
        case "2":
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
    
    init?(JSON: [String : AnyObject]) {
        
        guard let name = JSON["name"] as? String else {
            return nil
        }
        guard let make = JSON["manufacturer"] as? String else {
            return nil
        }
        guard let cost = JSON["cost_in_credits"] as? String, let costInCredits = Double(cost)  else {
            return nil
        }
        guard let length = JSON["length"] as? String else {
            return nil
        }
        guard let swClass = JSON["vehicle_class"] as? String else {
            return nil
        }
        guard let crew = JSON["crew"] as? String else {
            return nil
        }
        guard let capacity = JSON["cargo_capacity"] as? String, let cargoCapacity = Double(capacity) else {
            return nil
        }
        
        self.name = name
        self.make = make
        self.cost = costInCredits
        self.swClass = swClass
        self.crew = crew
        self.capacity = cargoCapacity
        
        let size = String(format:"%.2f", length.doubleValue)
        self.size = Double(size)!
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
    
    init?(JSON: [String : AnyObject]) {
        
        guard let name = JSON["name"] as? String else {
            return nil
        }
        guard let make = JSON["manufacturer"] as? String else {
            return nil
        }
        guard let cost = JSON["cost_in_credits"] as? String, let costInCredits = Double(cost)  else {
            return nil
        }
        guard let length = JSON["length"] as? String else {
            return nil
        }
        guard let swClass = JSON["starship_class"] as? String else {
            return nil
        }
        guard let crew = JSON["crew"] as? String else {
            return nil
        }
        guard let capacity = JSON["cargo_capacity"] as? String, let cargoCapacity = Double(capacity) else {
            return nil
        }
        
        self.name = name
        self.make = make
        self.cost = costInCredits
        self.swClass = swClass
        self.crew = crew
        self.capacity = cargoCapacity

        let size = String(format:"%.2f", length.doubleValue)
        self.size = Double(size)!

    }
}

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

