//
//  DeviceDetailTestViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 09/02/2022.
//

import UIKit

class DeviceDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewsCollectionView: UICollectionView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    
    var containerViewControllers: [ContainerViewController]?
    var settingsViwModel: DeviceSettingsViewModelType?
    var deviceType: DeviceCategoryEnum?
    
//    var selectedDetailCell: Int = 0 {
//        didSet(previousIndex) {
//            let previousSelected = menuCollectionView.cellForItem(at: IndexPath.init(row: previousIndex, section: 0)) as? DeviceDetailCell
//            if previousIndex != selectedDetailCell {
//                previousSelected?.setupBackgroundAsDeselected(type: .dashboard)
//            }
//        }
//    }
    
    //viewModels
    var viewModel: DeviceDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel?.inputs.viewDidLoad()
        self.setupContentView()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setupUI()
    }
    
    func setupUI() {
        self.menuCollectionView.delegate = self
        self.menuCollectionView.dataSource = self
        self.menuCollectionView.setCollectionHotizontalFlowLayoutWithSpacing()
        
        self.navigationItem.title = viewModel?.device.name
        self.setupBarItems()
        
        setupOutputs()
    }
    
    private func setupOutputs() {
        guard let viewModel = viewModel else {
            return
        }
        deviceType = DeviceCategoryEnum(rawValue: viewModel.device.type)
    }
    
    func setupBarItems() {
        guard let device = viewModel?.device else { return }
        self.setupFavouriteImage(isFavourite: device.favourite)
    }
    
    private func setupFavouriteImage(isFavourite: Bool) {
        //setup favourite image
        let startImage =  isFavourite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        let barButton = UIBarButtonItem(image: startImage, style: .done, target: self, action: #selector(favouriteButtonTapped))
        
        //setup settings image
        let gearShapeImg =  UIImage(systemName: "location.fill")
        let gaershapeBarButton = UIBarButtonItem(image: gearShapeImg, style: .done, target: self, action: #selector(gearshapeButtonTapped))
        
        //create buttons in navigation bar
        self.navigationItem.rightBarButtonItems = [barButton, gaershapeBarButton]

    }
    
    override func viewDidLayoutSubviews() {
        self.menuCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
    }
    
    private func setupContentView() {
        self.containerViewControllers = viewModel?.outputs.getContainerViewControllers
        
        guard let containerViewControllers = containerViewControllers else {
            return
        }

        for controller in containerViewControllers {
            addChild(controller)
            self.contentView.addSubview(controller.view)
            controller.didMove(toParent: self)
            controller.view.frame = self.contentView.bounds
            controller.view.isHidden = true
        }
        containerViewControllers[0].view.isHidden = false
    }
    
    private func hideAllControllersInContainer(){
        guard let containerViewControllers = self.containerViewControllers else {
            return
        }
        for controller in containerViewControllers {
            controller.view.isHidden = true
        }
    }
    
    static func instantiate() -> Self?{
        return UIStoryboard(name: "DeviceDetailView", bundle: nil).instantiateViewController(withIdentifier: "DeviceDetailViewController") as? Self
    }
    
    
    //MARK: Objc functions
    @objc func favouriteButtonTapped() {
        guard let device = viewModel?.device else { return }
        viewModel?.updateDeviceFavouriteState(device: device)
        self.setupFavouriteImage(isFavourite: device.favourite)
    }
    
    @objc func gearshapeButtonTapped() {
        /*
         OLD IMPL
         let slideVC = DeviceSettingsViewController()

         slideVC.delegate = self
         slideVC.viewModel = self.settingsViwModel
         slideVC.modalPresentationStyle = .custom
         slideVC.transitioningDelegate = self

         self.present(slideVC, animated: true, completion: nil)
         */

        let vc = DeviceSettingsModalViewController.instantiate()
        vc?.viewModel = settingsViwModel
        vc?.delegate = self
        self.navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
}

// MARK: Collection view settings
extension DeviceDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        selectedDetailCell = indexPath.row
        self.hideAllControllersInContainer()
        
        guard let containerViewControllers = containerViewControllers else {
            return
        }
        containerViewControllers[indexPath.row].view.isHidden = false
    }
}

extension DeviceDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch deviceType {
        case .disconnector:
            return DeviceCategoryEnum.disconnector.category.count
        case .meriTo:
            return DeviceCategoryEnum.meriTo.category.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceDetailCell", for: indexPath) as! DeviceDetailCell
    
        switch deviceType {
        case .disconnector:
            cell.setupCellDesign(with: DeviceCategoryEnum.disconnector.category[indexPath.row])
        case .meriTo:
            cell.setupCellDesign(with: DeviceCategoryEnum.meriTo.category[indexPath.row])
        default:
            cell.setupCellDesign(with: DeviceCategoryEnum.meriTo.category[indexPath.row])
        }
        
//        if indexPath.row == selectedDetailCell {
//            cell.setupBackgroundAsSelected(type: .dashboard)
//        }
        
        return cell
    }
}

extension DeviceDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenViewWidth = UIScreen.main.bounds.width
        let collectionViewHeight = collectionView.frame.size.height
        return CGSize(width: screenViewWidth / 3.5, height: collectionViewHeight )
    }
}

//// MARK: Transition view settings
//extension DeviceDetailViewController: UIViewControllerTransitioningDelegate {
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        let presentationVC = PresentationController(presentedViewController: presented, presenting: presenting)
//        presentationVC.presentationHeight  = .high
//        return presentationVC
//    }
//}


/*
 OLD Settings View Impl
 */
//extension DeviceDetailViewController: DeviceSettingsViewControllerDelegate {
//    func saveButtonPressed() {
//        guard let viewModel = viewModel, let container = viewModel.outputs.getContainerViewControllers else { return }
//        container[0].viewDidLoad()
//    }
//}

extension DeviceDetailViewController: DeviceSettingsModalViewDelegate {
    func saveButtonPressed() {
        guard let viewModel = viewModel, let container = viewModel.outputs.getContainerViewControllers else { return }
        container[0].viewDidLoad()
    }
}
