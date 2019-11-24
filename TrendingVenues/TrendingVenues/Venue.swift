//
//  Venue.swift
//  TrendingVenues
//
//  Created by Dobromir Penev on 24.11.19.
//  Copyright © 2019 Dobromir Penev. All rights reserved.
//

import Foundation
import CoreData

extension Venue {
    
    convenience init(fromJson json: [String : Any], context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = json["id"] as? String
        self.name = json["name"] as? String
        let location = json["location"] as? [String: Any]
        let address = Address(context: context)
        address.street = location?["address"] as? String
        address.city = location?["city"] as? String
        address.lat = location?["lat"] as? Double ?? 0
        address.lng = location?["lng"] as? Double ?? 0
        address.distance = location?["distance"] as? Int16 ?? 0
        self.address = address
    }
}
