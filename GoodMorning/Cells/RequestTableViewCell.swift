//
//  RequestTableViewCell.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UIButton!
    
    @IBOutlet var declineButton: UIButton!
    
    @IBOutlet var acceptButton: UIButton!
    
    @IBOutlet var profilePicImageView: UIImageView!
    
    var user: BackendlessUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        helping.putBorderOnButton(buttonView: profilePicImageView, radius: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
