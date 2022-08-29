//
//  DevicesTableViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 06/02/2022.
//

import UIKit


class DevicesTableViewCell: UITableViewCell {

    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceSpecificLocation: UILabel!
    
    func setupCellUI(device: StructuredDevice, deviceType: DeviceCategoryEnum) {
        if let image = self.deviceImage, let name = self.deviceName, let deviceSpecificLocation = self.deviceSpecificLocation {

            switch deviceType {
            case .disconnector:
                self.deviceImage.image = UIImage(named: "toggle-1")
            case .meriTo:
                self.deviceImage.image = UIImage(named: "electric pump big")
            }

            self.deviceImage.clipsToBounds = true
            
            name.text = device.deviceName
            deviceSpecificLocation.text = device.devicePlace
        }
    }
    
    func setupOnlineIndicator(messages: [DeviceOnlineStatusResponse], device: StructuredDevice) {
        let device = messages.filter {
            $0.device == device.deviceMac
        }.first
        
        guard let onlineStatus = device?.data.status else { return }
        
        if onlineStatus == .online {
            let circle = UIView(frame: CGRect(x: (self.deviceImage.bounds.width - 25), y:(self.deviceImage.bounds.height - 65), width: 15, height: 15))

            circle.layer.cornerRadius = circle.layer.bounds.width / 2
            circle.backgroundColor = UIColor.green
            circle.layer.borderWidth = 3
            circle.layer.borderColor = UIColor.white.cgColor
            circle.clipsToBounds = true
    
            self.deviceImage.addSubview(circle)
        } else {
            let circle = UIView(frame: CGRect(x: (self.deviceImage.bounds.width - 25), y:(self.deviceImage.bounds.height - 65), width: 15, height: 15))

            circle.layer.cornerRadius = circle.layer.bounds.width / 2
            circle.backgroundColor = UIColor.red
            circle.layer.borderWidth = 3
            circle.layer.borderColor = UIColor.white.cgColor
            circle.clipsToBounds = true
    
            self.deviceImage.addSubview(circle)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView?.contentMode = .scaleToFill
        self.imageView?.roundCorners([.allCorners], radius: 10)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            print(self.deviceName.text)
        }
    }
}
