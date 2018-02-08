//
//  SearchTableViewCell.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet var name: UIButton!
    
    @IBOutlet var friendButton: UIButton!
    
    @IBOutlet var profilePicImageView: UIImageView!
    
    var user: BackendlessUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       helping.putBorderOnButton(buttonView: profilePicImageView, radius: 17)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
