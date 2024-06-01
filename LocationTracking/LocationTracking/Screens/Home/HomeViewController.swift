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
        viewModel.view = view
        return view
    }
}

//MARK: - Inputs
extension HomeViewController: HomeViewInput {
    func setRegion(at location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 600, longitudinalMeters: 600)
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
