//
//  HomeViewModel.swift
//  LocationTracking
//
//  Created by Enes Sirkecioğlu on 31.05.2024.
//

import Foundation
import CoreLocation
import MapKit

protocol HomeViewOutput {
    func didViewLoad()
    func didSelect(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    func didTapStartTrackingButton()
    func didTapStopTrackingButton()
}

protocol HomeViewInput: AnyObject {
    func addMarker(at location: CLLocation, title: String)
    func setRegion(at location: CLLocation, latMeters: Double, longMeters: Double)
    func addCalloutView(_ address: String, annotationView: MKAnnotationView)
}

//MARK: - View Model
final class HomeViewModel: NSObject, HomeViewOutput {
    private var locationManager: CLLocationManager?
    private var lastLocation: CLLocation?
    private var totalDistance: CLLocationDistance = 0.0
    
    weak var delegate: HomeViewInput?
    
    func didViewLoad() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
    }
    
    func didSelect(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) {[weak self] (placemarks, error) in
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
        guard let locationManager else { return }
        locationManager.startUpdatingLocation()
    }
    
    func didTapStopTrackingButton() {
        guard let locationManager else { return }
        locationManager.stopUpdatingLocation()
        lastLocation = nil
    }
}

//MARK: - Location Delegate
extension HomeViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        if let lastLocation = lastLocation {
            let distance = newLocation.distance(from: lastLocation)
            totalDistance += distance
            
            if totalDistance >= 100 {
                delegate?.addMarker(at: newLocation, title: "100 metre ilerlediniz.")
                totalDistance = 0.0
            }
        } else {
            delegate?.addMarker(at: newLocation, title: "Başlangıç Noktası")
            totalDistance = 0.0
        }
        
        self.lastLocation = newLocation
        delegate?.setRegion(at: newLocation, latMeters: 400, longMeters: 400)
    }
}
