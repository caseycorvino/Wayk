//
//  MyAccTableViewCell.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class MyAccTableViewCell: UITableViewCell {

    @IBOutlet var profilePicImageView: UIImageView!
    
    @IBOutlet var wakeUpButton: UIButton!
    
    @IBOutlet var settingsButton: UIButton!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var requestsButton: UIButton!
    
    @IBOutlet var requestCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        helping.putBorderOnButton(buttonView: profilePicImageView, radius: 50)
        helping.putBorderOnButton(buttonView: wakeUpButton, radius: 20)
        helping.putBorderOnButton(buttonView: requestCount, radius: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
