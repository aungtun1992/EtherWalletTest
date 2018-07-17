//
//  WalletData.swift
//  etherWalletTest
//
//  Created by Activate on 17/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import Foundation

class WalletData{
    var type : String
    var address : String
    var balance : String
    public init(type: String, addr: String, bal: String){
        self.type = type
        address = addr
        balance = bal
    }
}
