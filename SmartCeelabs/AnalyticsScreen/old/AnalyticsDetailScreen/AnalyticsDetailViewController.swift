//
//  AnalyticsDetailScreenViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 24/01/2022.
//

import UIKit

class AnalyticsDetailViewController: UIViewController {
    
    @IBOutlet weak var timeLineCollectionView: UICollectionView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var analyticsDetailNavigationItem: UINavigationItem!
    
    var viewModel = AnalyticsDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.viewModel = AnalyticsDetailViewModel()
        self.setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    private func setupUI(){
        timeLineCollectionView.delegate = self
        timeLineCollectionView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .horizontal
        
        timeLineCollectionView.collectionViewLayout = layout
    }
}

extension AnalyticsDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = collectionView.bounds.height
        
        return CGSize(width: (width / 3), height: height)
    }
}
extension AnalyticsDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(AnalyticsTimeLineEnum.last7days.getByEachDay)
//        viewModel.getEnergyDataForChart(timeLineStructs: AnalyticsTimeLineEnum.last1day.getByEachDay, deviceToken: "840D8E39905C|1643068162|6175a23ce6ddc1d9575205113aa550d1e45f794af1b97a9c60618145d033754f")
//        tappedCellText = AnalyticsScreenCellEnum.allCases[indexPath.row].rawValue
//        self.performSegue(withIdentifier: "GoToAnalyticsDetailsSegue", sender: self)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "GoToAnalyticsDetailsSegue" {
//            let destinationNavigationController = segue.destination as! UINavigationController
//            let destinationVC = destinationNavigationController.topViewController as! AnalyticsDetailViewController
//            destinationVC.analyticsDetailNavigationItem.title = self.tappedCellText
//        }
//    }
}

extension AnalyticsDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let title = analyticsDetailNavigationItem.title else {return 0}
        let analyticsCategory = AnalyticsScreenCellEnum(rawValue: title)
        return analyticsCategory?.getTimelineItems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AnalyticsDetailCollectionViewCell =  collectionView.dequeueReusableCell(withReuseIdentifier: "AnalyticsDetailCollectionViewCell", for: indexPath) as! AnalyticsDetailCollectionViewCell
        
        guard let title = analyticsDetailNavigationItem.title else {return UICollectionViewCell()}
        let analyticsCategory = AnalyticsScreenCellEnum(rawValue: title)
        
        cell.cellLabel.text = analyticsCategory?.getTimelineItems[indexPath.row]
        
        return cell
    }
}
