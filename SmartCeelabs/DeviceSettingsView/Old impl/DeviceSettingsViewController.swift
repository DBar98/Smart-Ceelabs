//
//  DeviceSettingsViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 28/03/2022.
//

import UIKit
import MapKit

protocol DeviceSettingsViewControllerDelegate: AnyObject {
    func saveButtonPressed()
}

class DeviceSettingsViewController: BaseOverlayView, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var deviceMapView: MKMapView!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    
    //search view
    //
    
    var hasAddAnotation: Bool = false
    weak var delegate: DeviceSettingsViewControllerDelegate?
    
    let locationManager = CLLocationManager()
    let completer = MKLocalSearchCompleter()
    let regionInMeters: Double = 1000
    var deviceLocation: CLLocationCoordinate2D?
    
    var viewModel: DeviceSettingsViewModelType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        setupUI()
    }

    private func setupUI() {
        guard let viewModel = viewModel, let device = viewModel.outputs.device else {
            return
        }
        latitudeField.text = String(device.latitude)
        longitudeField.text = String(device.longitude)
        
        setupMapView()
        setupDeviceLocation()
        setupSearchView()
    }
    
    private func setupMapView() {
        let gestureRecognizer = UITapGestureRecognizer(
            target: self, action:#selector(handleTap))
        gestureRecognizer.delegate = self
        deviceMapView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func setupSearchView() {
        let searchVC = DeviceSearchViewController.instantiate()
        searchVC.viewModel = DeviceSearchViewModel()
        let searchController = UISearchController(searchResultsController: searchVC)
        
        searchController.searchResultsUpdater = self
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
        if let navigation = self.navigationController?.navigationItem {
            navigation.searchController = searchController
            
//            self.navigationItem.searchController = searchController
        }
      
    }
    
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        
        let location = gestureRecognizer.location(in: deviceMapView)
        let coordinate = deviceMapView.convert(location, toCoordinateFrom: deviceMapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        deviceMapView.removeAnnotations(self.deviceMapView.annotations)
        deviceMapView.addAnnotation(annotation)
        
        longitudeField.text = String(coordinate.longitude)
        latitudeField.text = String(coordinate.latitude)
        
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: coordinate.latitude, longitude:coordinate.longitude)) { (places, error) in
                if error == nil{
                    if let place = places {
                        print(place[0])
                        //here you can get all the info by combining that you can make address
                    }
                }
            }
    }
    
    @IBAction func clearAllButtonPressed(_ sender: Any) {
        latitudeField.text = ""
        longitudeField.text = ""
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let lat = latitudeField.text, let long = longitudeField.text else { return }
        if lat != "", long != "" {
            viewModel?.inputs.updateDeviceCoordinates(latitude: lat, longitude: long)
        }
        self.dismiss(animated: true, completion: nil)
        delegate?.saveButtonPressed()
    }
    
    @IBAction func currentLocationRequested(_ sender: Any) {
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        
        let currentLocation: CLLocation!
        
        currentLocation = locManager.location
        latitudeField.text = String(currentLocation.coordinate.latitude)
        longitudeField.text = String(currentLocation.coordinate.longitude)
    }
}
//MARK: LOCATION SERVICES

extension DeviceSettingsViewController {
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setupDeviceLocation() {
        //setup map view
        deviceMapView.roundCorners(.allCorners, radius: 5)

        //setup locations

        if let lat = latitudeField.text, let long = longitudeField.text {
            deviceLocation = CLLocationCoordinate2D(latitude: Double(lat) ?? 0,
                                                    longitude: Double(long) ?? 0)
        }
        if let deviceLocation = deviceLocation {
            checkLocationServices(coordinates: deviceLocation, title: "current location", subtitle: "test")
        }
    }
    
    
    private func centerViewOnUserLocation(coordinates: CLLocationCoordinate2D, title: String, subtitle: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = title
        annotation.subtitle = subtitle
        deviceMapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        deviceMapView.setRegion(region, animated: true)
    }
    
    
    private func checkLocationServices(coordinates: CLLocationCoordinate2D, title: String, subtitle: String) {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization(coordinates: coordinates, title: title, subtitle: subtitle)
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    
    private func checkLocationAuthorization(coordinates: CLLocationCoordinate2D, title: String, subtitle: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            deviceMapView.showsUserLocation = true
            centerViewOnUserLocation(coordinates: coordinates, title: title, subtitle: subtitle)
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        }
    }
}

extension DeviceSettingsViewController: CLLocationManagerDelegate {
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let lat = latitudeField.text, let long = longitudeField.text else { return }
//
//        let region = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: Double(lat) ?? 0, longitude: Double(long) ?? 0 ), latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        deviceMapView.setRegion(region, animated: true)
//    }
}

extension DeviceSettingsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        let searchVC = searchController.searchResultsController as? DeviceSearchViewController
        searchVC?.reloadWhenUserSearches(name: text)
    }
}
