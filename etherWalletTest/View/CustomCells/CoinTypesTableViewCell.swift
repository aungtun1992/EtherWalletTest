//
//  CoinTypesTableViewCell.swift
//  etherWalletTest
//
//  Created by Activate on 19/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit

class CoinTypesTableViewCell: UITableViewCell {

    @IBOutlet weak var coinLogo: UIImageView!
    @IBOutlet weak var coinTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
