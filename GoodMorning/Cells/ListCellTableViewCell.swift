//
//  ListCellTableViewCell.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class ListCellTableViewCell: UITableViewCell {

    @IBOutlet var nameField: UIButton!
    
    @IBOutlet var profilePic: UIImageView!
    
    var user: BackendlessUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        helping.putBorderOnButton(buttonView: profilePic, radius: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
