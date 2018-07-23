//
//  WalletData.swift
//  etherWalletTest
//
//  Created by Activate on 17/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import Foundation
import RealmSwift

class CoinData : Object{
    @objc dynamic var name : String = ""
    @objc dynamic var address : String = ""
    @objc dynamic var balance : String = ""
    let tokens = List<TokenData>()
}

