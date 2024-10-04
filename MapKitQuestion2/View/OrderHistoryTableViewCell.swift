//
//  OrderHistoryTableViewCell.swift
//  MapKitQuestion2
//
//  Created by Nguyen Van Chien on 4/10/24.
//

import UIKit

class OrderHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var btnReturn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
