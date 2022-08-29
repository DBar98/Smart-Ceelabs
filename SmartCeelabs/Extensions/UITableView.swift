//
//  UITableView.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 26/02/2022.
//

import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(cell: T.Type) {
        let identifier = String(describing: cell)
        register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
}
