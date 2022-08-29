//
//  StatsScreenTableViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 19/02/2022.
//

import UIKit

class StatsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellContent: UIView!
    @IBOutlet weak var cellCollectionView: UICollectionView!
    
    var sectionName: StatsColectionElementEnum?
    var viewModel: StatsViewModelType?
    var parentVC: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellUI()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupCell(sectionName: StatsColectionElementEnum, viewModel: StatsViewModelType?, parentVC: UIViewController) {
        self.sectionName = sectionName
        self.parentVC = parentVC
        self.viewModel = viewModel
    }
    
    private func setupCellUI() {
        self.cellCollectionView.delegate = self
        self.cellCollectionView.dataSource = self
        self.cellCollectionView.setCollectionHotizontalFlowLayoutWithSpacing()
    }

}

extension StatsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenViewWidth = UIScreen.main.bounds.width
        let collectionViewHeight = collectionView.frame.size.height
        return CGSize(width: screenViewWidth / 2.5, height: collectionViewHeight )
    }
}

extension StatsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionName = sectionName else { return 0 }
        return sectionName.elementCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCollectionViewCell", for: indexPath) as? StatsCollectionViewCell
        guard let sectionName = sectionName else { return UICollectionViewCell() }

        cell?.cellLabel.text = sectionName.elementCategories[indexPath.row]
        cell?.setupCellUI(statsEnergyElement: sectionName)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? StatsCollectionViewCell
        guard let cellText = selectedCell?.cellLabel.text else { return }
        
        viewModel?.inputs.goToDestinationViewController(viewController: sectionName ?? .profile, parentVC: self.parentVC ?? UIViewController(), titleForVC: cellText)
    }
}
