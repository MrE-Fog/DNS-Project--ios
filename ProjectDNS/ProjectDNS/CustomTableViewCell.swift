//
//  CustomTableViewCell.swift
//  ProjectDNS
//
//  Created by venky N on 11/01/23.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    
    @IBOutlet private var viewBg: UIView!
    @IBOutlet private var serviceName: UILabel!
    @IBOutlet private var IPAddress: UILabel!
    @IBOutlet private var port: UILabel!
    @IBOutlet private var serviceType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
    func configure(data: NetService, IpAddressData: String) {
        viewBg.layer.backgroundColor = UIColor.systemBrown.cgColor
        viewBg.layer.shadowColor = UIColor.black.cgColor
        viewBg.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        viewBg.layer.shadowOpacity = 0.2
        viewBg.layer.shadowRadius = 4.0
        viewBg.layer.cornerRadius = 10
        serviceName.text = "\(data.name)"
        serviceType.text = "\(data.type)"
        port.text = "\(data.port)"
        IPAddress.text = IpAddressData
        
    }
}
