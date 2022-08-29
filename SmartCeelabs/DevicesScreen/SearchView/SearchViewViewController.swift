//
//  SearchViewViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 21/03/2022.
//

import UIKit

class SearchViewViewController: UIViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        self.setupUI()

    }
    
    
    func setupUI() {
        if self.searchDeviceTableView != nil {
            self.searchDeviceTableView.delegate = self
            self.searchDeviceTableView.dataSource = self
            self.searchDeviceTableView.register(cell: StatsTableViewCell.self)
        }
       
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell
        
        if let cell = cell {
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
}

extension SearchViewViewController: UITableViewDelegate {
    
}
