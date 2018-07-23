//
//  WalletTypes.swift
//  etherWalletTest
//
//  Created by Activate on 19/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import Foundation
import RealmSwift

class Coin{
    var name : String
    var imageName : String
    init(name : String, imageName : String?) {
        self.name = name
        if let im = imageName {
            self.imageName = im
        }else{
            self.imageName = "default"
        }
    }
}

class Token : Coin {
    var tokenAddress : String
    var type : String = "ERC20"
    init(name : String, tokenAddress : String, type : String = "ERC20", imageName : String = "default"){
        self.tokenAddress = tokenAddress
        super.init(name: name, imageName: imageName)
    }
}

class WalletTypes{
    let realm = try! Realm()
    
    var coinDetails : [String : Coin] = ["Ethereum" : Coin(name: "Ethereum", imageName: "EthereumIcon"),
                                         "Bitcoin" : Coin(name: "Bitcoin", imageName: "BitcoinIcon")]
    
    var tokenDetails : [String : Token] = ["Binance" : Token(name: "Binance", tokenAddress: "0xb8c77482e45f1f44de1745f52c74426c631bdd52", imageName: "BinanceIcon")
                                               ]
    var tokensInRealm : Results<TokenData>?
    
    public init(){
        tokensInRealm = realm.objects(TokenData.self)
        if let _customTokens = tokensInRealm {
            _customTokens.forEach { (customToken) in
                let token = Token(name: customToken.name, tokenAddress: customToken.tokenAddress, imageName: "default")
                tokenDetails[customToken.name] = token
            }
        }
    }
    
    func addCustomToken(name: String, tokenAddr: String){
        //check if the adddrss already exist
        var isCustomToken = true
        
        //Check if the address is already predefined
        tokenDetails.values.forEach { (token) in
            if token.tokenAddress == tokenAddr {
                print("Debug: Existing Token address \(token.tokenAddress) is same as \(token.tokenAddress)")
                isCustomToken = false
                return
            }
        }
        //If the address is not predefined yet =>
        if isCustomToken {
            //Add the CustomToken to predefied list
            let token = Token(name: name, tokenAddress: tokenAddr)
            tokenDetails[name] = token
            print("Debug: it is the custom token \(token.tokenAddress)")
        }
        
    }
    func addToken(name : String, tokenAddr: String, tokenOwner: String, balance: String){

        //Add the CustomToken to predefied list
        let token = Token(name: name, tokenAddress: tokenAddr,  imageName: "default")
        tokenDetails[name] = token
        //Create CustomToken and Save in Relam
        let tkn = TokenData()
        tkn.name = name
        tkn.tokenAddress = tokenAddr
        tkn.ownerAddress = tokenOwner
        tkn.balance = balance
        saveTokenDataToRealm(token: tkn)
    }
    
    func saveTokenDataToRealm(token: TokenData){
        do{
            try realm.write{
                realm.add(token)
            }
        }catch{
            print("Debug: there is an error while writing token data to relam")
        }
    }
}
