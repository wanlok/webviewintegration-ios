//
//  MessageTableViewCell.swift
//  webviewintegration
//
//  Created by WAN Tung Lok on 28/12/2020.
//  Copyright © 2020 Robert Wan. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
