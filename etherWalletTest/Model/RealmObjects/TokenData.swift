//
//  CustomTokens.swift
//  etherWalletTest
//
//  Created by Activate on 19/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import Foundation
import RealmSwift

class TokenData : Object {
    @objc dynamic internal var name: String = ""
    @objc dynamic internal var tokenAddress: String = ""
    @objc dynamic internal var balance: String = ""
    @objc dynamic internal var type: String = "ERC20"
    var ownerAddr = LinkingObjects(fromType: CoinData.self, property: "tokens")
}
