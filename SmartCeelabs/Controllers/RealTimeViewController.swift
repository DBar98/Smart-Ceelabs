//
//  RealTimeController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 27/06/2021.
//

import UIKit

class RealTimeViewController: ContainerViewController{
    
    @IBOutlet weak var realTimeCollection: UICollectionView!
    var tappedCellText: String = ""
    var deviceToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realTimeCollection.delegate = self
        realTimeCollection.dataSource = self
        realTimeCollection.collectionViewLayout = UICollectionViewFlowLayout()

    }
}

extension RealTimeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return realTimeCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RealTimeCell", for: indexPath) as! RealTimeCollectionCell
        cell.setupRealTimeCell(with: realTimeCells[indexPath.row])
        return cell
    }
}

extension RealTimeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: (width / 2) - 15, height: (width / 2) - 15)
    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
}

extension RealTimeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tappedCellText = analyticsCells[indexPath.row].bottomLabel
        self.performSegue(withIdentifier: "GoToRealTimeDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToRealTimeDetails" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let destinationVC = destinationNavigationController.topViewController as! RealTimeDetailsViewController
//            destinationVC.viewModel = RealTimeViewModel(token:"240AC494BFE000|1644944087|3d866f7fbba3753d4a2d731357cbcbf612a5b19adb18280c056ba37dd02152c1")
            destinationVC.realTimeDetailsTitle.title = tappedCellText
//            destinationVC.subtitleText = "Real time " + tappedCellText.lowercased() + " profile"
//                destinationVC.chosenData = tappedCellText
        }
    }
}
