//
//  HomeViewController.swift
//  LocationTracking
//
//  Created by Enes Sirkecioğlu on 31.05.2024.
//

import UIKit
import MapKit

//MARK: - View
final class HomeViewController: UIViewController, MKMapViewDelegate {
    private var mapView: MKMapView!
    private var currentCalloutView: CustomCalloutView?
    
    private let viewModel: HomeViewOutput
    private init(viewModel: HomeViewOutput) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        
        viewModel.didViewLoad()
    }
    
    static func generateModule() -> HomeViewController {
        let viewModel =  HomeViewModel()
        let view = HomeViewController(viewModel: viewModel)
        viewModel.delegate = view
        return view
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: CustomCalloutView.reuseIdentifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: CustomCalloutView.reuseIdentifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        viewModel.didSelect(mapView, didSelect: view)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let currentCalloutView = currentCalloutView {
            currentCalloutView.removeFromSuperview()
            self.currentCalloutView = nil
        }
    }
}

//MARK: - Inputs
extension HomeViewController: HomeViewInput {
    func addCalloutView(_ address: String, annotationView: MKAnnotationView) {
        let calloutView = CustomCalloutView()
        calloutView.setAddress(address)
        self.currentCalloutView = calloutView
        
        annotationView.addSubview(calloutView)
        
        calloutView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calloutView.centerXAnchor.constraint(equalTo: annotationView.centerXAnchor),
            calloutView.bottomAnchor.constraint(equalTo: annotationView.topAnchor, constant: -16),
            calloutView.widthAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
    }
    
    func setRegion(
        at location: CLLocation,
        latMeters: Double,
        longMeters: Double
    ) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: latMeters, longitudinalMeters: longMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func addMarker(at location: CLLocation, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
}

//MARK: - Private Functions
private extension HomeViewController {
    
}
