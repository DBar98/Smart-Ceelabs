//
//  DisconnectorViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 03/02/2022.
//

import UIKit
import MapKit
import CoreLocation

protocol DisconnectorViewDelegate: AnyObject {
    func outputNameChanged()
}

class DisconnectorViewController: ContainerViewController {
    
    @IBOutlet weak var disconnectorOutletsCollection: UICollectionView!
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var mapKitView: MKMapView!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 4000
    var deviceLocation: CLLocationCoordinate2D?
    
    
    var viewModel: DisconnectorViewModelType?
    var slideViewModel: RelayActionViewModel?
    var outputOverlayViewModel: OutputSettingsViewModelType?
    
    var disconnector: DisconnectorModel?
    weak var delegate: DisconnectorViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.inputs.fetchDataFromWebSocket()
        self.setupUI()
        self.setupInptus()
        self.setupOutputs()
    }
    
    private func setupUI(){
        disconnectorOutletsCollection.delegate = self
        disconnectorOutletsCollection.dataSource = self
        disconnectorOutletsCollection.collectionViewLayout = setupCollectionVerticalFlowLayout(scrollDirection: .vertical)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.updateCounting()
        })
        
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    
    private func setupInptus() {
        viewModel?.inputs.fetchRelayData()
    }
    
    private func setupOutputs() {
        viewModel?.outputs.onDisconnectorFetch = {[weak self] (disconnectorModel) in
            self?.disconnector = disconnectorModel
            DispatchQueue.main.async {
                self?.disconnectorOutletsCollection.reloadData()
            }
        }
        
        setupDeviceLocation()
    }
    
    private func setupDeviceLocation() {
        //setup mapView
        mapKitView.roundCorners(.allCorners, radius: 5)
        //setup location
        if let latitude = viewModel?.outputs.device.latitude, let longitude = viewModel?.outputs.device.longitude {
            deviceLocation = CLLocationCoordinate2D(latitude: latitude,
                                                    longitude: longitude)
        }
        
        if let deviceLocation = deviceLocation {
//            let address = getAddressByCoordinates(lat: viewModel?.outputs.device.latitude ?? 0.0, long: viewModel?.outputs.device.longitude ?? 0.0)
            let address = CLGeocoder.init()

            address.reverseGeocodeLocation(CLLocation.init(latitude: viewModel?.outputs.device.latitude ?? 0.0, longitude: viewModel?.outputs.device.longitude ?? 0.0)) { (places, error) in
                if error == nil{
                    if let place = places{
                        
                        if !place.isEmpty{
                            let name = place[0].name ?? ""
                            let area = place[0].locality ?? ""
                            let placemark: String = name + " " + area
                            self.checkLocationServices(coordinates: deviceLocation, title: "Location of \(self.viewModel?.outputs.device.name ?? "device")", subtitle: placemark)
                        }
                    }
                }
            }
        }
    }
    
    private  func setupCollectionVerticalFlowLayout(scrollDirection: UICollectionView.ScrollDirection) -> UICollectionViewFlowLayout{
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.scrollDirection = scrollDirection
        return layout
    }
    
    var timer = Timer()
    
    func updateCounting(){
        for data in webSocketResponsesArray {
            disconnector?.relay1.state = data.data.r1 ?? false
            disconnector?.relay2.state = data.data.r2 ?? false
            disconnector?.relay3.state = data.data.r3 ?? false
            disconnector?.relay4.state = data.data.r4 ?? false
            
            DispatchQueue.main.async {
                self.disconnectorOutletsCollection.reloadData()
            }
        }
    }
    
    //MARK: setup slide vs's
    private func showRelayOverlay(relayIdx: Int) {
        let slideVC = RelayActionView()
        slideVC.viewModel = self.slideViewModel
        slideVC.relayIdx = relayIdx
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    private func showRelayOutputSetttingsView() {
        if disconnector != nil {
            let slideVC = OutputSettingsOverlayViewController()
            slideVC.disconnector = disconnector
            slideVC.viewModel = outputOverlayViewModel
            slideVC.delegate = self
            
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            self.present(slideVC, animated: true, completion: nil)
        }
    }
}

//MARK: IBA actions
extension DisconnectorViewController {
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        showRelayOutputSetttingsView()
    }
    
    @IBAction func showActionPressed(_ sender: Any) {
        guard let device = viewModel?.outputs.device else { return }
        let region = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: device.latitude, longitude: device.longitude), latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapKitView.setRegion(region, animated: true)
    }
}

//MARK: CollectionView Setup
extension DisconnectorViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collectionViewCell: DisconectorOutletCollectionViewCell = disconnectorOutletsCollection.dequeueReusableCell(withReuseIdentifier: "DisconectorOutletCollectionViewCell", for: indexPath) as! DisconectorOutletCollectionViewCell
        
        collectionViewCell.setupCellUI()
        
        if let disconnector = disconnector {
            collectionViewCell.outletName.text = disconnector.getRelayByIndexNumber(index: indexPath.row).name
            collectionViewCell.energyValue.text = String(disconnector.getRelayByIndexNumber(index: indexPath.row).energy ?? 0 ) + "Wh"
            collectionViewCell.relaySwitch.isOn = disconnector.getRelayByIndexNumber(index: indexPath.row).state
            collectionViewCell.viewModel = self.viewModel
            collectionViewCell.setupUI(index: indexPath.row, disconnector: disconnector)
        }
        return collectionViewCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showRelayOverlay(relayIdx: indexPath.row)
    }
}

extension DisconnectorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenViewWidth = UIScreen.main.bounds.width
        let collectionViewHeight = collectionView.frame.size.height
        return CGSize(width: screenViewWidth / 2.2, height: collectionViewHeight / 2.2)
    }
}

// MARK: Transition view settings
extension DisconnectorViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationVC = PresentationController(presentedViewController: presented, presenting: presenting)
        presentationVC.presentationHeight = .medium
        
        return presentationVC
    }
}

// MARK: - Setup Device Location
extension DisconnectorViewController {
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    private func centerViewOnUserLocation(coordinates: CLLocationCoordinate2D, title: String, subtitle: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = title
        annotation.subtitle = subtitle
        
        mapKitView.removeAnnotations(mapKitView.annotations)
        mapKitView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapKitView.setRegion(region, animated: true)
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
            mapKitView.showsUserLocation = true
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
    
    private func getAddressByCoordinates(lat: Double, long: Double) -> String? {
        let address = CLGeocoder.init()
        
        var placemark: String?
        address.reverseGeocodeLocation(CLLocation.init(latitude: lat, longitude: long)) { (places, error) in
            if error == nil{
                if let place = places{
                    placemark = place[0].administrativeArea
                    print(place[0].name)
                }
            }
        }
        return placemark
    }
}

extension DisconnectorViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setupDeviceLocation()
    }
}
//MARK: Output Slide delegate
extension DisconnectorViewController: OutputSettingsOverlayViewDelegate {
    func onOutputNameChange(disconnector: DisconnectorTableModel) {
        DispatchQueue.main.async {
            self.disconnector?.relay1.name = disconnector.relay1
            self.disconnector?.relay2.name = disconnector.relay2
            self.disconnector?.relay3.name = disconnector.relay3
            self.disconnector?.relay4.name = disconnector.relay4
            
            self.disconnectorOutletsCollection.reloadData()
            self.delegate?.outputNameChanged()
        }
    }
}
