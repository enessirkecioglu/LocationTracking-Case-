//
//  HomeViewModel.swift
//  LocationTracking
//
//  Created by Enes Sirkecioğlu on 31.05.2024.
//

import Foundation
import CoreLocation

protocol HomeViewOutput {
    func didViewLoad()
}

protocol HomeViewInput: AnyObject {
    func addMarker(at location: CLLocation, title: String)
    func setRegion(at location: CLLocation)
}

//MARK: - View Model
final class HomeViewModel: NSObject, HomeViewOutput {
    private var locationManager: CLLocationManager!
    private var lastLocation: CLLocation?
    private var totalDistance: CLLocationDistance = 0.0
    
    weak var view: HomeViewInput?
    
    func didViewLoad() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

//MARK: - Location Delegate
extension HomeViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        if let lastLocation = lastLocation {
            let distance = newLocation.distance(from: lastLocation)
            totalDistance += distance
            
            print(totalDistance)
            if totalDistance >= 100 {
                view?.addMarker(at: newLocation, title: "100 metre ilerlediniz.")
                totalDistance = 0.0
            }
        } else {
            self.lastLocation = newLocation
            view?.addMarker(at: newLocation, title: "Başlangıç Noktası")
        }
        
        self.lastLocation = newLocation
        
        view?.setRegion(at: newLocation)
    }
}
