//
//  HomeViewController.swift
//  LocationTracking
//
//  Created by Enes Sirkecioğlu on 31.05.2024.
//

import UIKit
import MapKit

//MARK: - Protocol
protocol HomeViewOutput {
    var isTracking: Bool { get }
    
    func didLoadView()
    func didSelect(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    func didTapStartTrackingButton()
    func didTapStopTrackingButton()
    func didTapResetButton()
}

//MARK: - View
final class HomeViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var trackingButton: UIButton!
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
        
        mapView.delegate = self
        setTrackingButton(viewModel.isTracking)
        viewModel.didLoadView()
    }
    
    static func generateModule() -> HomeViewController {
        let viewModel =  HomeViewModel()
        let view = HomeViewController(viewModel: viewModel)
        viewModel.delegate = view
        return view
    }
}

//MARK: - Actions
private extension HomeViewController {
    @IBAction func didTapTrackingButton(_ sender: Any) {
        if viewModel.isTracking {
            viewModel.didTapStopTrackingButton()
        } else {
            viewModel.didTapStartTrackingButton()
        }
    }
    
    @IBAction func didTapResetButton(_ sender: Any) {
        viewModel.didTapResetButton()
    }
}

//MARK: - Inputs
extension HomeViewController: HomeViewInput {
    func removeOverlaysAndAnnotations() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func drawLine(coordinates: [CLLocationCoordinate2D]) {
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
    }
    
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
    
    func setTrackingButton(_ isTracking: Bool) {
        let title = isTracking ? "Durdur" : "İzlemeyi Başlat"
        let image = UIImage(systemName: isTracking ? "pause.fill" : "play.fill")
        let backgroundColor: UIColor = isTracking ? .systemPink : .systemGreen
        
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = image
        config.background.backgroundColor = backgroundColor
        config.imagePadding = 8
        trackingButton.configuration = config
    }
}

//MARK: - MapView Delegate
extension HomeViewController: MKMapViewDelegate {
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer()
    }
}
