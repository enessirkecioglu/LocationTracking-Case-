//
//  CodableLocation.swift
//  LocationTracking
//
//  Created by Enes Sirkecioğlu on 2.06.2024.
//

import MapKit

struct CodableLocation: Codable {
    var latitude: Double
    var longitude: Double
    
    init(from location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
