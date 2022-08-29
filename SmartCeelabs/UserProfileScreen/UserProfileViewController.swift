//
//  UserProfileViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 07/03/2022.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var infoTableView: UITableView!
    
    let viewModel = UserProfileViewModel()
    
    var cellKeys: [String] = ["Email",
                              "All Devices",
                              "MeriTO Base",
                              "MeriTO Control",
                              "About Us"]
    var cellValues: [String] = []
    
    var cellInfoDict: [String : String] = [
                                           "Email" : "",
                                           "All Devices": "",
                                           "MeriTO Base": "",
                                           "MeriTO Control": "",
                                           "About Us": ""
                                          ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        setupOutputs()
        setupUI()
    }
    
    private func setupUI() {
        setupTableView()
        viewModel.retrieveProfileTableViewData()

        userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true

    }
    
    private func setupTableView() {
        infoTableView.dataSource = self
        infoTableView.delegate = self
        infoTableView.register(cell: UserProfileTableViewCell.self)

    }
    
    
    func setupOutputs() {
        self.userName.text = viewModel.outputs.name
        if let image = viewModel.outputs.image {
            self.userImage.image = image
        }
        
        viewModel.outputs.onDevicesFetch = { [weak self ] tableViewModel in
            
            self?.cellValues.append(contentsOf: [tableViewModel.email,
                               String(tableViewModel.deviceCoint),
                               String(tableViewModel.meriTOBaseCount),
                               String(tableViewModel.meriTOControllerCount),
                               tableViewModel.smartCeelabsWeb])
           
                        
            self?.infoTableView.reloadData()
        }
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        viewModel.logout()
    }
}

extension UserProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cellKeys.count - 1 {
            let webViewVC = WebViewViewController.instantiate()
            self.navigationController?.present(webViewVC,
                                               animated: true,
                                               completion: nil)
        }
    }
}

extension UserProfileViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "User info"
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileTableViewCell", for: indexPath) as! UserProfileTableViewCell
                
        cell.setupCell(keyLabel: cellKeys[indexPath.row], value: cellValues[indexPath.row])
        return cell
    }
}
