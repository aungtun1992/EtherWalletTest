//
//  WalletTableViewCell.swift
//  etherWalletTest
//
//  Created by Activate on 16/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var coinSymbol: UIImageView!
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var coinAmount: UILabel!
    @IBOutlet weak var coinAddress: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
