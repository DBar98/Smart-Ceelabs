//
//  UIImageViewExtension.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 04/04/2022.
//
import UIKit

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
