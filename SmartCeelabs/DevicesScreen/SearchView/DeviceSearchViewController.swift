//
//  DeviceSearchViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 21/03/2022.
//

import UIKit

class DeviceSearchViewController: UIViewController {

    @IBOutlet weak var deviceSearchTableView: UITableView!
    var viewModel: DeviceSearchViewModel?
    var deviceDetailViewModel: DeviceDetailViewModel?
    var foundDevices: [Device]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.deviceSearchTableView.delegate = self
        self.deviceSearchTableView.dataSource = self
        self.deviceSearchTableView.register(cell: SearchTableViewCell.self)
    }
    
    func reloadWhenUserSearches(name: String) {
        viewModel?.inputs.getDevicesByName(name: name)
        
        viewModel?.outputs.onDeviceFetch = {[weak self ] devs in
            self?.foundDevices = devs
            DispatchQueue.main.async {
                self?.deviceSearchTableView.reloadData()
            }
        }
    }
    
    
    static func instantiate() -> Self {
        return UIStoryboard(name: "DeviceSearchView", bundle: nil).instantiateViewController(withIdentifier: "DeviceSearchViewController") as! Self
    }
}

extension DeviceSearchViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deviceDetailVC = DeviceDetailViewController.instantiate()
        guard let deviceDetailVC = deviceDetailVC else {
            return
        }

        guard let device = foundDevices else { return }
        viewModel?.pushToDeviceSearchViewController(parent: self, detailVC: deviceDetailVC, device: device[indexPath.row])
    }
}

extension DeviceSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundDevices?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell

        guard let devices = foundDevices, let cell = cell else { return UITableViewCell()}
        cell.setupCellUI(device: devices[indexPath.row])
        return cell
    }
}
