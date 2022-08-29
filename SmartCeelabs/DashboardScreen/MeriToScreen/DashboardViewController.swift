//
//  DeviceDetailViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 17/01/2022.
//

import UIKit
import MapKit
import CoreLocation
import Charts

class ContainerViewController: BaseViewController {
}

class DashboardViewController: ContainerViewController, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mapKitView: MKMapView!
    let locationManager = CLLocationManager()
    let completer = MKLocalSearchCompleter()
    let regionInMeters: Double = 1000
    var deviceLocation: CLLocationCoordinate2D?

    
    @IBOutlet weak var deviceNameNavigation: UINavigationItem!
    @IBOutlet weak var infoCollectionView: UICollectionView!
    @IBOutlet weak var activeEnergyChartView: UIView!
    @IBOutlet weak var activeEnrgySegmentControl: UISegmentedControl!
    @IBOutlet weak var reactiveEnergyChartView: UIView!
    @IBOutlet weak var quadrantsCollection: UICollectionView!
    @IBOutlet weak var locationView: UIView!
    
    var activeBarChart = BarChartView()
    var reactiveBarChart = BarChartView()
    
    var viewModel: DashboardViewModelType?
    var currentDeviceToken: String = ""
    var currentMacAddress: String = ""
    
    override var onAppActiveBecome: (() -> ())? {
        reloadCollectionView
    }
    
    override var onAppWillEnterForeground: (() -> ())? {
        reloadCollectionView
    }
    
    var reactiveChartTimeInnterval: EnergyDataTimeIntervalsEnum = .last24Hours {
        didSet {
            setupReactiveChartView(isFirstInitialized: false)
        }
    }
    var currentReactiveChartData: EnergyDataOutputsEnum = .Q1 {
        didSet {
            setupReactiveChartView(isFirstInitialized: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //fetch process has to start when view apper, no when loads.
        viewModel?.inputs.fetchDataFromWebSocket(deviceToken: self.currentDeviceToken)
        
//        NotificationCenter.default.addObserver(self, selector:#selector(reloadCollectionView),
//                                               name: UIApplication.willEnterForegroundNotification,
//                                               object: UIApplication.shared)
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(reloadCollectionView),
//                                               name: UIApplication.didBecomeActiveNotification,
//                                               object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.inputs.stopFetchingDataFromWebSocket()
    }
    
    override func viewDidLayoutSubviews() {
        viewModel?.inputs.setupRealTimeCellValues(currentViewController: self)
        
        activeBarChart.frame = CGRect(x: 0, y: 0, width: activeEnergyChartView.frame.width, height: activeEnergyChartView.frame.height)
        reactiveBarChart.frame = CGRect(x: 0, y: 0, width: reactiveEnergyChartView.frame.width, height: reactiveEnergyChartView.frame.height)

        self.activeEnergyChartView.addSubview(activeBarChart)
        self.reactiveEnergyChartView.addSubview(reactiveBarChart)
        
        self.quadrantsCollection.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)

    }
    
    private func setupUI(){
        
        infoCollectionView.delegate = self
        infoCollectionView.dataSource = self
        infoCollectionView.collectionViewLayout = setupCollectionVerticalFlowLayout(scrollDirection: .vertical)
        
        quadrantsCollection.delegate = self
        quadrantsCollection.dataSource = self
        quadrantsCollection.collectionViewLayout = setupCollectionVerticalFlowLayout(scrollDirection: .horizontal)
        
        // Prepare charts
        prepareCharts()
                
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showOverlay))
        
        // Initial setup of charts
        setupActiveChartView(timeline: .last24Hours, isFirstInitialized: true)
        setupReactiveChartView(isFirstInitialized: true)
        
        // Implement time intervals
        viewModel?.inputs.setupStaticCellValues(viewController: self, token: currentDeviceToken, timeFrom: StaticTimeIntervalEnum.today.getTimeInterval, dateInterval: "Today")
        viewModel?.inputs.setupRealTimeCellValues(currentViewController: self)
        
        // Show device on map
        setupDeviceLocation()
    }
    
    private func setupActiveChartView(timeline: EnergyDataTimeIntervalsEnum, isFirstInitialized: Bool) {
        viewModel?.inputs.fetchEnergyData(energyDataType: "E_I", timeline: timeline , barChart: activeBarChart, selectedDataType: .energyImport, controller: self, isFirstInitialized: isFirstInitialized)
    }
    
    private func setupReactiveChartView(isFirstInitialized: Bool) {
        viewModel?.inputs.fetchEnergyData(energyDataType: currentReactiveChartData.energyShortcut, timeline: reactiveChartTimeInnterval , barChart: reactiveBarChart, selectedDataType: currentReactiveChartData, controller: self, isFirstInitialized: isFirstInitialized)
    }
    
    
    private func prepareCharts() {
        viewModel?.inputs.prepareChart(barChart: activeBarChart)
        viewModel?.inputs.prepareChart(barChart: reactiveBarChart)
    }
    
    func stopWebsocketFetching() {
        viewModel?.inputs.stopFetchingDataFromWebSocket()
    }
    
    func reloadCollectionView() {
        viewModel?.inputs.fetchDataFromWebSocket(deviceToken: self.currentDeviceToken)
    }
    
    private func setupDeviceLocation() {
        //setup map view
        mapKitView.roundCorners(.allCorners, radius: 5)
//        mapKitView
//        let gestureRecognizer = UITapGestureRecognizer(
//                                      target: self, action:#selector(handleTap))
//            gestureRecognizer.delegate = self
//            mapKitView.addGestureRecognizer(gestureRecognizer)
       
        
        //setup locations
        if let latitude = viewModel?.outputs.device.latitude, let longitude = viewModel?.outputs.device.longitude {
            deviceLocation = CLLocationCoordinate2D(latitude: latitude,
                                                    longitude: longitude)
        }
        
        if let deviceLocation = deviceLocation {
            completer.delegate = self
            completer.region = MKCoordinateRegion(center: deviceLocation, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
            completer.queryFragment = "Technicom"
        }
       
        if let deviceLocation = deviceLocation {
            
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
//            checkLocationServices(coordinates: deviceLocation, title: "Location of \(viewModel?.outputs.device.name ?? "device")", subtitle: "test")
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        
        let timeIntervals: [String] = StaticTimeIntervalEnum.allCases.map {$0.rawValue}
        
        self.present(UIAlertController
                        .showAlertWithNumberOfOptions(title: "Statistics report",
                                                      message: "Choose time interval for statistics report",
                                                      options: timeIntervals,
                                                      choiceButtonHandler: { [weak self] (time: String, chosenTimeInterval: String) in
            guard let self = self else {return}
            
            self.viewModel?.inputs.setupStaticCellValues(viewController: self, token: self.currentDeviceToken, timeFrom: time, dateInterval: chosenTimeInterval)
        }),
                     animated: true,
                     completion: nil)
        
    }
    @IBAction func activeEnergySegmentControlPressed(_ sender: UISegmentedControl) {
        let segmentValue = sender.titleForSegment(at: sender.selectedSegmentIndex)
        guard let segmentValue = segmentValue else {return}
        let timeInterval = EnergyDataTimeIntervalsEnum(rawValue: segmentValue)
        
        guard let timeInterval = timeInterval else { return }
        setupActiveChartView(timeline: timeInterval, isFirstInitialized: false)
    }
    
    @IBAction func reactiveEnergySegmentPressed(_ sender: UISegmentedControl) {
        let segmentValue = sender.titleForSegment(at: sender.selectedSegmentIndex)
        guard let segmentValue = segmentValue else {return}
        
        self.reactiveChartTimeInnterval = EnergyDataTimeIntervalsEnum(rawValue: segmentValue) ?? .last24Hours
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        guard let device = viewModel?.outputs.device else { return }
        let region = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: device.latitude, longitude: device.longitude), latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapKitView.setRegion(region, animated: true)
    }
    
    @objc func showOverlay() {
        let slideVC = OverlayView()
        slideVC.deviceToken = currentDeviceToken
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        slideVC.overlayDelegate = self
        self.present(slideVC, animated: true, completion: nil)
        slideVC.macAddress?.text = currentMacAddress
    }
    
    @objc func showPickerView(){
        print("PICKER VIEW")
    }
    
    
    func setupCollectionVerticalFlowLayout(scrollDirection: UICollectionView.ScrollDirection) -> UICollectionViewFlowLayout{
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.scrollDirection = scrollDirection
        return layout
    }
}

// MARK: - Setup CollectionViews
extension DashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == quadrantsCollection{
            return ReactiveEnergyOutputsEnum.allCases.count
        }
        else {
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
            
        case quadrantsCollection:
            let cell: QuadrantCollectionViewCell = quadrantsCollection.dequeueReusableCell(withReuseIdentifier: "QuadrantCollectionViewCell", for: indexPath) as! QuadrantCollectionViewCell
            cell.cellLabel.text = ReactiveEnergyOutputsEnum.allCases[indexPath.row].rawValue
            cell.setupCell()
            return cell
            
            
        case infoCollectionView:
            let cell: InfoCollectionCell = infoCollectionView.dequeueReusableCell(withReuseIdentifier: "InfoCollectionCell", for: indexPath) as! InfoCollectionCell
            cell.nameLabel.text = DashboardRealTimeMenuEnum.allCases[indexPath.row].rawValue
            cell.setCellBackgroundColor()
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension DashboardViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenViewWidth = UIScreen.main.bounds.width
        let collectionViewHeight = collectionView.frame.size.height
        
        if collectionView == infoCollectionView {
            return CGSize(width: screenViewWidth / 2.2, height: collectionViewHeight / 2.2)
        } else if collectionView == quadrantsCollection {
            return CGSize(width: screenViewWidth / 4, height: collectionViewHeight / 1.2)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.quadrantsCollection {
            let selectedCell = collectionView.cellForItem(at: indexPath) as! QuadrantCollectionViewCell
            
            guard let selectedCellText = selectedCell.cellLabel.text else {return}
            
//            let selectedDataEnum = ReactiveEnergyOutputsEnum(rawValue: selectedCellText)
            let selectedDataEnum = EnergyDataOutputsEnum(rawValue: selectedCellText)
            self.currentReactiveChartData = selectedDataEnum ?? .Q1
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

// MARK: - Setup Slide VC

extension DashboardViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationVC = PresentationController(presentedViewController: presented, presenting: presenting)
        presentationVC.presentationHeight  = .high
        return presentationVC
    }
}

extension LoginViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

//MARK: - Settings Overlay Delegate
extension DashboardViewController: OverlayViewDelegate{
    func saveButtonPressed(deviceName: String) {
        deviceNameNavigation.title = deviceName
        mapKitView.removeAnnotations(self.mapKitView.annotations)
    }
}

// MARK: - Setup Device Location
extension DashboardViewController {
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    private func centerViewOnUserLocation(coordinates: CLLocationCoordinate2D, title: String, subtitle: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = title
        annotation.subtitle = subtitle
        
        //remove and add new annotation
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
}

extension DashboardViewController: CLLocationManagerDelegate {
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let device = viewModel?.outputs.device else { return }
//        let region = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: device.latitude, longitude: device.longitude), latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapKitView.setRegion(region, animated: true)
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setupDeviceLocation()
    }
}

extension DashboardViewController: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        let addresses = completer.results.map { result in
            result.title + ", " + result.subtitle
        }
        print(addresses)
        // use addresses, e.g. update model and call `tableView.reloadData()
        
        let address = "1 Infinite Loop, Cupertino, CA 95014"

            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(addresses[0]) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
                }
                print(location.coordinate.latitude)
                // Use your location
            }
    }

}
