//
//  LocationUserDefaults.swift
//  LocationTracking
//
//  Created by Enes Sirkecioğlu on 1.06.2024.
//

import Foundation

final class LocationUserDefaults {
    
    enum DefaultsKey: String {
        case route
    }
    
    static let shared = LocationUserDefaults()
    private let defaults = UserDefaults.standard
    
    private init() { }
    
    func set(_ value: Any?, key: DefaultsKey) {
        defaults.setValue(value, forKey: key.rawValue)
    }
    
    func get(key: DefaultsKey) -> Any? {
        return defaults.value(forKey: key.rawValue)
    }
    
    func remove(for key: DefaultsKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
}
