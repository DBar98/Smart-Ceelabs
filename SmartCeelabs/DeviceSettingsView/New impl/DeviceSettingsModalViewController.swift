//
//  DeviceSettingsModalViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 14/04/2022.
//

import UIKit
import MapKit

protocol DeviceSettingsModalViewDelegate: AnyObject {
    func saveButtonPressed()
}

class DeviceSettingsModalViewController: BaseOverlayView, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var deviceMapView: MKMapView!
//    @IBOutlet weak var latitudeField: UITextField!
//    @IBOutlet weak var longitudeField: UITextField!
    
    var hasAddAnotation: Bool = false
    weak var delegate: DeviceSettingsModalViewDelegate?
    
    let locationManager = CLLocationManager()
    let completer = MKLocalSearchCompleter()
    let regionInMeters: Double = 1000
    var deviceLocation: CLLocationCoordinate2D?
    
    var device: Device?
    var deviceLat: String = ""
    var deviceLong: String = ""
    
    var searchController: UISearchController?
    var searchViewController = LocationSearchViewController.instantiate()
    
    var viewModel: DeviceSettingsViewModelType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupUI() {
        guard let viewModel = viewModel, let device = viewModel.outputs.device else {
            return
        }
//        longitudeField.delegate = self
//        latitudeField.delegate = self
//        latitudeField.text = String(device.latitude)
//        longitudeField.text = String(device.longitude)
//
        self.device = device
        self.deviceLat = String(device.latitude)
        self.deviceLong = String(device.longitude)
        
        setupNavigation()
        setupMapView()
        setupDeviceLocation()
        setupSearchView()
    }
    
    private func setupNavigation() {
        self.navigationItem.title = "Set device location"
    }
    
    private func setupSearchView() {
        let searchVC = searchViewController
        
        searchController = UISearchController(searchResultsController: searchVC)
        searchVC.delegate = self
        
        searchController?.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = searchController
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
    }
    
    static func instantiate() -> Self? {
        return UIStoryboard(name: "DeviceSettingsModalView", bundle: nil).instantiateViewController(withIdentifier: "DeviceSettingsModalViewController") as? Self
    }
    private func setupMapView() {
        let gestureRecognizer = UITapGestureRecognizer(
            target: self, action:#selector(handleTap))
        gestureRecognizer.delegate = self
        deviceMapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        
        let location = gestureRecognizer.location(in: deviceMapView)
        let coordinate = deviceMapView.convert(location, toCoordinateFrom: deviceMapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        deviceMapView.removeAnnotations(self.deviceMapView.annotations)
        deviceMapView.addAnnotation(annotation)
        
//        longitudeField.text = String(coordinate.longitude)
//        latitudeField.text = String(coordinate.latitude)
        
        self.deviceLat = String(coordinate.latitude)
        self.deviceLong = String(coordinate.longitude)
        
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
    
    @IBAction func saveButtonPressed(_ sender: Any) {
//        guard let lat = latitudeField.text, let long = longitudeField.text else { return }
        
//        if lat != "", long != "" {
            viewModel?.inputs.updateDeviceCoordinates(latitude: deviceLat, longitude: deviceLong)
//        }
        self.dismiss(animated: true, completion: nil)
        delegate?.saveButtonPressed()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func currentLocationRequested(_ sender: Any) {
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        
        let currentLocation: CLLocation!
        
        currentLocation = locManager.location
        deviceLat = String(currentLocation.coordinate.latitude)
        deviceLong = String(currentLocation.coordinate.longitude)
        
        setupDeviceLocation()
    }
}
//MARK: LOCATION SERVICES

extension DeviceSettingsModalViewController {
    private func setupLocationManager() {
//        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setupDeviceLocation() {
        //setup map view
        deviceMapView.roundCorners(.allCorners, radius: 5)
        
        //setup locations
        
//        if let lat = latitudeField.text, let long = longitudeField.text {
            deviceLocation = CLLocationCoordinate2D(latitude: Double(deviceLat) ?? 0,
                                                    longitude: Double(deviceLong) ?? 0)
//        }
        if let deviceLocation = deviceLocation {
            checkLocationServices(coordinates: deviceLocation, title: "Found location", subtitle: viewModel?.outputs.device?.name ?? "")
        }
    }
    
    
    private func centerViewOnUserLocation(coordinates: CLLocationCoordinate2D, title: String, subtitle: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = title
        annotation.subtitle = subtitle
        
        deviceMapView.removeAnnotations(deviceMapView.annotations)
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
    
    private func getCoordinatesFromAddress(address: String) {
        let geoCoder = CLGeocoder()
        
        if address != nil {
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else {
                    return
                }
//                self.latitudeField.text = String(location.coordinate.latitude)
//                self.longitudeField.text = String(location.coordinate.longitude)
                self.deviceLong = String(location.coordinate.longitude)
                self.deviceLat = String(location.coordinate.latitude)
                
                self.setupDeviceLocation()
            }
        }
    }
}

extension DeviceSettingsModalViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        completer.delegate = self
        completer.region = MKCoordinateRegion(center: deviceMapView.userLocation.coordinate, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
        completer.queryFragment = text
    }
}

extension DeviceSettingsModalViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        let addresses: [(String, String)] = completer.results.map { result in
            (result.title + ", " ,
            result.subtitle)
        }
        
        searchViewController.addresses = addresses
    }
}


extension DeviceSettingsModalViewController: LocationSearchViewDelegate {
    func onAddressPick(address: String) {
        getCoordinatesFromAddress(address: address)
    }
}

extension DeviceSettingsModalViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        super.isFromSearchView = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        super.isFromSearchView = true
    }
}
