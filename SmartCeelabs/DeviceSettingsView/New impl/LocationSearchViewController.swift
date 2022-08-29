//
//  LocationSearchViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 14/04/2022.
//

protocol LocationSearchViewDelegate: AnyObject {
    func onAddressPick(address: String)
}

import UIKit

class LocationSearchViewController: UIViewController {

    @IBOutlet weak var locationsTableView: UITableView!
    
    var addresses: [(String, String)] = [] {
        didSet {
            locationsTableView.reloadData()
        }
    }
    
    weak var delegate: LocationSearchViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        locationsTableView.delegate = self
        locationsTableView.dataSource = self
        locationsTableView.register(cell: LocationTableViewCell.self)
        locationsTableView.keyboardDismissMode = .onDrag // or .interactive
    }
    
    static func instantiate() -> Self {
        return UIStoryboard(name: "LocationSearchView", bundle: nil).instantiateViewController(withIdentifier: "LocationSearchViewController") as! Self
    }
}

extension LocationSearchViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if !self.addresses.isEmpty {
                print(self.addresses[indexPath.row].1)
                
                //send full address including name of location
//                self.delegate?.onAddressPick(address: self.addresses[indexPath.row].0 + self.addresses[indexPath.row].1)
                
                //send just address
                self.delegate?.onAddressPick(address: self.addresses[indexPath.row].1)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(40)
    }
}

extension LocationSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as? LocationTableViewCell

        guard let cell = cell else { return UITableViewCell() }
        cell.address.text = addresses[indexPath.row].0 + addresses[indexPath.row].1
        return cell
    }
}
