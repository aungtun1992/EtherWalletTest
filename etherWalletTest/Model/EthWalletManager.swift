//
//  WalletObject.swift
//  etherWalletTest
//
//  Created by Activate on 16/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import Foundation
import web3swift

enum networkType {
    case localTestNet
    case infuraMainnet
    case infuraRinkeby
}

class EthWalletManager {

    var bip32KSManager : KeystoreManager
    var bip32KS : BIP32Keystore?
    var appDir : String
    var ksExist : Bool
    var web3Net : web3?
    
    public init(){
        //Get the user directory
        appDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        //Search for keystore files at the user directory
        if let ksM = KeystoreManager.managerForPath(appDir + "/bip32_keystore", scanForHDwallets: true){
            
            bip32KSManager = ksM

            if (bip32KSManager.addresses?.count == 0) {
                print("Debug: There is no existing keystore in user directory - \(appDir)")
                ksExist = false
            } else {
                print("Debug: There is an key store in user directory")
                print("Debug: BIP 32 Keystore Manager Addresses - \(bip32KSManager.addresses![0])")

                
                bip32KS = (bip32KSManager.walletForAddress((bip32KSManager.addresses![0])) as? BIP32Keystore)!
                
                print("Debug: BIP 32 Keystore Addresses - \(String(describing: bip32KS!.addresses))")
                print("Debug: BIP 32 Keystore isHDKeyStore - \(bip32KS!.isHDKeystore)")
                print("Debug: BIP 32 Keystore params - \(String(describing: bip32KS!.keystoreParams))")
                print("Debug: BIP 32 Keystore root prefix - \(bip32KS!.rootPrefix)")
                
                ksExist = true
                
                //Set up web3
                setWeb3Network(type: .localTestNet)
                web3Net!.addKeystoreManager(bip32KSManager)
            }
        }else{
            print("Debug: There is a problem while retriving keystore manager")
            fatalError("There is a problem while retriving keystore manager")
        }
    }
    public convenience init?(mnemonicWords: String){
        self.init()
        
        //Get the user directory
        appDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        do{
            print("Debug: Creating new keystore using mnemonics")
            bip32KS = try (BIP32Keystore.init(mnemonics: mnemonicWords, password: Strings().password))!
            bip32KSManager = KeystoreManager([bip32KS!])
            ksExist = true
            //Set up web3
            setWeb3Network(type: .localTestNet)
            web3Net!.addKeystoreManager(bip32KSManager)
            
            let keydata = try JSONEncoder().encode(bip32KS!.keystoreParams)
            FileManager.default.createFile(atPath: appDir + "/bip32_keystore"+"/key.json", contents: keydata, attributes: nil)
        }catch{
            print("Debug: There is a problem while initializing and saving bip32 keystore")
            print(error)
        }
    }
//    func initBIP32KS(mnemonicWords: String){
//        do{
//            bip32KS = try (BIP32Keystore.init(mnemonics: mnemonicWords, password: Strings().password))!
//            saveBIP32Key()
//        }catch{
//            print("Debug: There is a problem while initializing and saving bip32 keystore")
//            print(error)
//        }
//    }
    func addNewWallet(){
        do{
            try bip32KS!.createNewChildAccount(password: Strings().password)
        }catch{
            print("Debug: There is a problem while creating bip32ks child account")
            print(error)
        }
        saveBIP32Key()
    }
    func saveBIP32Key() {
        do{
            let keydata = try JSONEncoder().encode(bip32KS!.keystoreParams)
            FileManager.default.createFile(atPath: appDir + "/bip32_keystore"+"/key.json", contents: keydata, attributes: nil)
        }catch{
            print("Debug: There is a problem while saving bip32 keystore")
            print(error)
        }
    }
    func setWeb3Network(type : networkType){
        switch type {
        case .localTestNet:
            if let w3 = Web3.new(URL(string: "http://localhost:8545")!){
                web3Net = w3
            }else{
                print("Debug: Thre is a problem forming url: localhost:8545")
                print("Debug: Setting the network to infura rinkey")
                web3Net = Web3.InfuraRinkebyWeb3()
            }
        case .infuraMainnet:
            web3Net = Web3.InfuraMainnetWeb3()
        case .infuraRinkeby:
            web3Net = Web3.InfuraRinkebyWeb3()
        }
        
    }
}
