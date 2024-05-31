//
//  HomeViewController.swift
//  LocationTracking
//
//  Created by Enes Sirkecioğlu on 31.05.2024.
//

import UIKit
import MapKit

final class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    private var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    private var lastLocation: CLLocation?
    private var totalDistance: CLLocationDistance = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        if let lastLocation = lastLocation {
            let distance = newLocation.distance(from: lastLocation)
            totalDistance += distance
            
            print(totalDistance)
            if totalDistance >= 100 {
                addMarker(at: newLocation)
                totalDistance = 0.0
            }
        } else {
            self.lastLocation = newLocation
            addMarker(at: newLocation)
        }
        
        self.lastLocation = newLocation
        
        let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 600, longitudinalMeters: 600)
        mapView.setRegion(region, animated: true)
    }
}

//MARK: - Private Functions
private extension HomeViewController {
    func addMarker(at location: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "Konum: \(location.coordinate.latitude), \(location.coordinate.longitude)"
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 600, longitudinalMeters: 600)
        mapView.setRegion(region, animated: true)
    }
}
