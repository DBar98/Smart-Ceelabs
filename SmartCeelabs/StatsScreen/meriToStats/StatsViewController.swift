//
//  StatsScreenViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 19/02/2022.
//

import UIKit

class StatsViewController: ContainerViewController {

    @IBOutlet weak var statsTableView: UITableView!
    
    var viewModel: StatsViewModelType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        self.statsTableView.dataSource = self
        self.statsTableView.delegate = self
    }
}

extension StatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

extension StatsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return StatsColectionElementEnum.allCases[section].rawValue
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatsTableViewCell", for: indexPath) as! StatsTableViewCell
        cell.setupCell(sectionName: StatsColectionElementEnum.allCases[indexPath.section],
                       viewModel: self.viewModel,
                       parentVC: self)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = .label
        header.textLabel?.frame = header.bounds

        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }
}

