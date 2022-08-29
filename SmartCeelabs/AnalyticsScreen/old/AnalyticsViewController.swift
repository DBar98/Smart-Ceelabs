//
//  AnalyticsViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 23/01/2022.
//

import UIKit

class AnalyticsViewController: ContainerViewController {
    
    @IBOutlet weak var analyticsCollectionView: UICollectionView!
    var tappedCellText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    func setupUI(){
        analyticsCollectionView.dataSource = self
        analyticsCollectionView.delegate = self
        analyticsCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
}
extension AnalyticsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: (width / 2) - 15, height: (width / 2) - 15)
    }
}
extension AnalyticsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tappedCellText = AnalyticsScreenCellEnum.allCases[indexPath.row].rawValue
        self.performSegue(withIdentifier: "GoToAnalyticsDetailsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToAnalyticsDetailsSegue" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let destinationVC = destinationNavigationController.topViewController as! AnalyticsDetailViewController
            destinationVC.analyticsDetailNavigationItem.title = self.tappedCellText
        }
    }
}


extension AnalyticsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AnalyticsScreenCellEnum.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnalyticsScreenCell", for: indexPath) as! AnalyticsScreenCell
        
        cell.setupCellDesign(index: indexPath.row)
          return cell
    }
}
