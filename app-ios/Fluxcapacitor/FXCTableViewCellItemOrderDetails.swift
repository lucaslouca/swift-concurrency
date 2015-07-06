//
//  FXCTableViewCellItemOrderDetails.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 07/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCTableViewCellItemOrderDetails: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
