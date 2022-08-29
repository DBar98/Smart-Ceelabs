//
//  DevicesViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 14/01/2022.
//

import UIKit
import RealmSwift

class DeviceViewController: UIViewController{
    
    @IBOutlet weak var analyticsDeviceCollectionView: UICollectionView!
    @IBOutlet weak var controllDeviceCollectionView: UICollectionView!
    
    var viewModel = DeviceViewModel()
    
    let searchController = UISearchController()
    var cellText: String = ""
    var structuredDeviceData: Dictionary<String, [StructuredDevice]> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDeviceCollectionViews()
        navigationItem.searchController = searchController
        viewModel.getUserDevicesHierarchy()
        self.setupOutputs()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        analyticsDeviceCollectionView.reloadData()
        controllDeviceCollectionView.reloadData()
    }
    
    func setupDeviceCollectionViews() {
        self.analyticsDeviceCollectionView.delegate = self
        self.analyticsDeviceCollectionView.dataSource = self
        
        self.controllDeviceCollectionView.delegate = self
        self.controllDeviceCollectionView.dataSource = self
        
        self.analyticsDeviceCollectionView.collectionViewLayout = setupCollectionVerticalFlowLayout()
        self.controllDeviceCollectionView.collectionViewLayout = setupCollectionVerticalFlowLayout()
        
    }
    
    
    private func setupOutputs(){
        
        viewModel.outputs.onStructuredDeviceFetch = { [weak self] (dict) in
            DispatchQueue.main.async {
                self?.structuredDeviceData = dict
                self?.analyticsDeviceCollectionView.reloadData()
            }
        }
    }
    
    func setupCollectionVerticalFlowLayout() -> UICollectionViewFlowLayout{
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .horizontal
        
        return layout
    }
}

extension DeviceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.analyticsDeviceCollectionView {
            return structuredDeviceData.count
        } else if collectionView == self.controllDeviceCollectionView {
            return viewModel.getUserDevicesByGivenType(type: .controll).count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.analyticsDeviceCollectionView{
            let cell: AnalyticsDeviceCell = analyticsDeviceCollectionView.dequeueReusableCell(withReuseIdentifier: "AnalyticsDeviceCell", for: indexPath) as! AnalyticsDeviceCell
            let device = viewModel.getUserDevicesByGivenType(type: .analytics)[indexPath.row]
            cell.analyticsLabel.text = device.name
            cell.token = device.token
            cell.macAddress = device.mac
            cell.analyticsContentView.addShadowAndBounds()
            return cell
        } else if collectionView == self.controllDeviceCollectionView {
            let cell: ControllDeviceCell = controllDeviceCollectionView.dequeueReusableCell(withReuseIdentifier: "ControlDeviceCell", for: indexPath) as! ControllDeviceCell
            let device = viewModel.getUserDevicesByGivenType(type: .controll)[indexPath.row]
            cell.upperLabel.text = device.name
            cell.macAddress = device.mac
            cell.token = device.token
            cell.cellView.addShadowAndBounds()
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension DeviceViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenViewWidth = UIScreen.main.bounds.width
        let collectionViewHeight = collectionView.frame.size.height
        
        if collectionView == self.analyticsDeviceCollectionView {
            return CGSize(width: screenViewWidth / 1.5, height: collectionViewHeight / 4.5)
        } else if collectionView == self.controllDeviceCollectionView {
            return CGSize(width: screenViewWidth / 3, height: collectionViewHeight / 2)
        }
        return .zero
    }

//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView == self.analyticsDeviceCollectionView{
//            let selectedCell = collectionView.cellForItem(at: indexPath) as! AnalyticsDeviceCell
//            viewModel.goToDeviceDetailController(cellText: selectedCell.analyticsLabel.text ?? "", token: selectedCell.token, parentViewController: self, deviceType: .analytics)
//        } else if collectionView == self.controllDeviceCollectionView {
//            let selectedCell = collectionView.cellForItem(at: indexPath) as! ControllDeviceCell
//            viewModel.goToDeviceDetailController(cellText: selectedCell.upperLabel.text ?? "", token: selectedCell.token, parentViewController: self, deviceType: .controll)
//        }
//    }

}
