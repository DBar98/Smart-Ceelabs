//
//  DevicesViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 06/02/2022.
//

import UIKit

class DevicesViewController: UIViewController {

    @IBOutlet weak var favouriteDevicesLabel: UILabel!
    @IBOutlet weak var favouriteCollectionHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var favouriteDevicesCollectionView: UICollectionView!
    @IBOutlet weak var devicesTableView: UITableView!
    @IBOutlet weak var favouritesView: UIView!
    @IBOutlet weak var favouritesViewLeadingConstrain: NSLayoutConstraint!
    @IBOutlet weak var devicesNavigationItem: UINavigationItem!
    
    var viewModel: DeviceViewModel = DeviceViewModel()
    var onlineStatuses: [DeviceOnlineStatusResponse] = []
    var buildings: [String] = []
    var devices: [[StructuredDevice]] = []
    var favouriteDevices: [Device]? = []
    var tableSection = 0
    var timer = Timer()
    
    let favouriteExistsLabel = "Favourite devices"
    let favouriteDoesntExistsLabel = "No favourite devices to display"
    let titleLabel = "Devices"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        setupInputs()
        setupOutputs()
    }
    
    func setupUI() {
        let searchVC = DeviceSearchViewController.instantiate()
        searchVC.viewModel = DeviceSearchViewModel()
        let searchController = UISearchController(searchResultsController: searchVC)
        
//        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 252, green: 252, blue: 252)
//        self.devicesTableView.backgroundColor = UIColor(red: 252, green: 252, blue: 252)
        self.devicesTableView.sectionHeaderHeight = CGFloat(40)
        
        self.favouriteDevicesCollectionView.delegate = self
        self.favouriteDevicesCollectionView.dataSource = self
        self.favouriteDevicesCollectionView.setCollectionHotizontalFlowLayoutWithSpacing()
        self.favouriteDevicesCollectionView.register(UINib(nibName: "FavouritesCellView", bundle: nil), forCellWithReuseIdentifier: "FavouritesCollectionViewCell")
        
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.navigationItem.title = titleLabel
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.favouriteDevices = self.viewModel.inputs.getFavouriteDevices(structuredDevices: devices.flatMap { $0 })
        self.favouriteDevicesCollectionView.reloadData()
        setupFavouriteDevicesView()
    }
    
    func setupInputs() {
        viewModel.inputs.fetchDevicesOnlineState()
        viewModel.inputs.updateDeviceDtoNames(structuredDevices: devices)
    }
    
    private func setupOutputs(){
        self.devices.removeAll()
        viewModel.getUserDevicesHierarchy()
        devicesTableView.delegate = self
        devicesTableView.dataSource = self
        
        viewModel.outputs.onStructuredDeviceFetch = { [weak self] devicesDictionary in

            self?.buildings = Array(devicesDictionary.keys)
            
            for key in devicesDictionary.keys {
                if let device = devicesDictionary[key]{
                    self?.devices.append(device)
                }
            }
            self?.viewModel.inputs.updateDeviceDtoNames(structuredDevices: self?.devices ?? [])
            self?.devicesTableView.reloadData()
            
            if let devices = self?.devices  {
                self?.favouriteDevices?.removeAll()

                self?.favouriteDevices = (self?.viewModel.inputs.getFavouriteDevices(structuredDevices: devices.flatMap { $0 }))
                self?.favouriteDevicesCollectionView.reloadData()
                self?.setupFavouriteDevicesView()
                
                self?.viewModel.outputs.onDeviceStatusesFetch = { [weak self] statuses in
                    self?.onlineStatuses = statuses
                    DispatchQueue.main.async {
                        self?.devicesTableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func setupFavouriteDevicesView() {
        if let favouriteDevices = favouriteDevices, favouriteDevices.isEmpty {
            favouriteCollectionHeightConstrain.constant =  0
            favouriteDevicesLabel.text = favouriteDoesntExistsLabel
        } else {
            favouriteCollectionHeightConstrain.constant =  60
            favouriteDevicesLabel.text = favouriteExistsLabel

        }
    }
    
    static func instantiate() -> Self? {
       return UIStoryboard(name: "Devices", bundle: nil).instantiateViewController(withIdentifier: "DevicesViewController") as? Self
    }
}

//MARK: - UITableViewDelegate
extension DevicesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.goToDeviceDetailController(parentViewController: self, strucutredDevice: devices[indexPath.section][indexPath.row], realmDevice: nil)
    }
}

//MARK: - UITableViewDataSource
extension DevicesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.tableSection = section
        return buildings[section]
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return buildings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DevicesTableViewCell", for: indexPath) as! DevicesTableViewCell
        let structuredDevice = devices[indexPath.section][indexPath.row]
        let deviceDto = viewModel.inputs.getDeviceDtoByDeviceMac(mac: structuredDevice.deviceMac)
        
        guard let deviceDto = deviceDto, let category = DeviceCategoryEnum(rawValue: deviceDto.type) else {
            return UITableViewCell()
        }
        
        cell.setupCellUI(device: structuredDevice, deviceType: category)
       
//        if !onlineStatuses.isEmpty {
//            cell.setupOnlineIndicator(messages: onlineStatuses, device: structuredDevice)
//        }
        
        return cell
    }
}

//MARK: - UISearchViewDelegae
extension DevicesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        let searchVC = searchController.searchResultsController as? DeviceSearchViewController
        searchVC?.reloadWhenUserSearches(name: text)

    }
}

//MARK: - UICollectionViewDelegae
extension DevicesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let favouriteDevices = favouriteDevices else { return }
        
        viewModel.inputs.goToDeviceDetailController(parentViewController: self, strucutredDevice: nil, realmDevice: favouriteDevices[indexPath.row])
    }
}

extension DevicesViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.inputs.getFavouriteDevices(structuredDevices: self.devices.flatMap { $0 }).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavouritesCollectionViewCell", for: indexPath) as? FavouritesCollectionViewCell
        guard let favouriteDevices = favouriteDevices else {return UICollectionViewCell()}
        cell?.setupCellUI(device: favouriteDevices[indexPath.row])
        return cell ?? UICollectionViewCell()
    }
}

extension DevicesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height + 8, height: collectionView.frame.height)
    }
}
