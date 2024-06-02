//
//  HomeViewModel.swift
//  LocationTracking
//
//  Created by Enes Sirkecioğlu on 31.05.2024.
//

import Foundation
import CoreLocation
import MapKit

//MARK: - Protocol
protocol HomeViewInput: AnyObject {
    func addMarker(at location: CLLocation, title: String)
    func setRegion(at location: CLLocation, latMeters: Double, longMeters: Double)
    func drawLine(coordinates: [CLLocationCoordinate2D])
    func addCalloutView(_ address: String, annotationView: MKAnnotationView)
    func setTrackingButton(_ isTracking: Bool)
    func removeOverlaysAndAnnotations()
}

//MARK: - View Model
final class HomeViewModel: NSObject, HomeViewOutput {
    private(set) var isTracking: Bool = true
    
    private var locationManager: CLLocationManager?
    private var lastLocation: CLLocation?
    private var totalDistance: CLLocationDistance = 0.0
    private var trackedLocations: [[CLLocation]] = []
    
    weak var delegate: HomeViewInput?
    private let locationDefaults: LocationUserDefaults = .shared
    
    //MARK: - View Delegates
    func didLoadView() {
        //Setup location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        
        //Load Route
        let loadedRoute = loadSavedRoute()
        trackedLocations = loadedRoute.map { $0.map { $0.location }}
        drawRoute(locations: trackedLocations)
        drawMarkers(locations: trackedLocations)
        
        //Setup Tracking
        if isTracking {
            startTracking()
        }
    }
    
    func didTapResetButton() {
        //Set State
        trackedLocations.removeAll()
        delegate?.removeOverlaysAndAnnotations()
        
        //Remove saved route
        locationDefaults.remove(for: .route)
        
        //Stop Tracking
        stopTracking()
    }
    
    func didSelect(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        let location = CLLocation(
            latitude: annotation.coordinate.latitude,
            longitude: annotation.coordinate.longitude
        )
        
        CLGeocoder().reverseGeocodeLocation(location) {[weak self] (placemarks, error) in
            if error != nil {
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            let address = """
                \(placemark.name ?? ""),
                \(placemark.locality ?? ""),
                \(placemark.administrativeArea ?? ""),
                \(placemark.country ?? "")
                """
            
            self?.delegate?.addCalloutView(address, annotationView: view)
        }
    }
    
    func didTapStartTrackingButton() {
        startTracking()
    }
    
    func didTapStopTrackingButton() {
        stopTracking()
    }
}

//MARK: - Private Functions
private extension HomeViewModel {
    func startTracking() {
        guard let locationManager else { return }
        
        //Set State
        isTracking = true
        delegate?.setTrackingButton(isTracking)
        
        //Add new segment
        trackedLocations.append([])
        
        //Start tracking
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        guard let locationManager else { return }
        
        //Set State
        lastLocation = nil
        isTracking = false
        delegate?.setTrackingButton(isTracking)
        
        //Stop tracking
        locationManager.stopUpdatingLocation()
    }
    
    func drawRoute(locations: [[CLLocation]]) {
        for location in locations {
            let coordinates = location.map { $0.coordinate }
            delegate?.drawLine(coordinates: coordinates)
        }
    }
    
    func drawMarkers(locations: [[CLLocation]]) {
        var lastLocation: CLLocation?
        var distanceSinceLastMarker: CLLocationDistance = 0
        for segment in locations {
            for location in segment {
                if let last = lastLocation {
                    let distance = last.distance(from: location)
                    distanceSinceLastMarker += distance
                    if distanceSinceLastMarker >= 100 {
                        delegate?.addMarker(at: location, title: "100 metre ilerlediniz.")
                        distanceSinceLastMarker = 0
                    }
                } else {
                    delegate?.addMarker(at: location, title: "Başlangıç Noktası")
                    distanceSinceLastMarker = 0
                }
                lastLocation = location
            }
        }
    }
    
    func saveRoute() {
        let codableLocations = trackedLocations.map { $0.map { CodableLocation(from: $0) } }
        if let data = try? JSONEncoder().encode(codableLocations) {
            locationDefaults.set(data, key: .route)
        }
    }
    
    func loadSavedRoute() -> [[CodableLocation]] {
        guard let data = locationDefaults.get(key: .route) as? Data else {
            return []
        }
        
        guard let decodedLocations = try? JSONDecoder().decode([[CodableLocation]].self, from: data) else {
            return []
        }
        
        return decodedLocations
    }
}

//MARK: - Location Delegate
extension HomeViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        if trackedLocations.isEmpty {
            trackedLocations.append([newLocation])
        } else {
            trackedLocations[trackedLocations.count - 1].append(newLocation)
        }
        saveRoute()
        
        if let lastLocation = lastLocation {
            let distance = newLocation.distance(from: lastLocation)
            totalDistance += distance
            
            if totalDistance >= 100 {
                delegate?.addMarker(at: newLocation, title: "100 metre ilerlediniz.")
                totalDistance = 0.0
            }
            
            let area = [lastLocation.coordinate, newLocation.coordinate]
            delegate?.drawLine(coordinates: area)
        } else {
            delegate?.addMarker(at: newLocation, title: "Başlangıç Noktası")
            totalDistance = 0.0
        }
        
        self.lastLocation = newLocation
        delegate?.setRegion(at: newLocation, latMeters: 400, longMeters: 400)
    }
}
