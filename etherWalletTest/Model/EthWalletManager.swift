//
//  WalletObject.swift
//  etherWalletTest
//
//  Created by Activate on 16/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import Foundation
import web3swift
import BigInt
import RealmSwift

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
    
    func setWeb3Network(type : networkType){
        switch type {
        case .localTestNet:
            if let w3 = Web3.new(URL(string: "http://localhost:8545")!){
                web3Net = w3
            }else if let w3 = Web3.new(URL(string: "https://ropsten.infura.io/hUhRL9mj1fUrWIhQW9tH")!){
                print("Debug: Thre is a problem forming url: localhost:8545")
                print("Debug: Setting the network to infura ropsten")
                web3Net = w3
            }
            else{
                print("Debug: Thre is a problem forming url: localhost:8545 and infura opsten")
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

//MARK: - Ethereum Coin Handling
extension EthWalletManager{
    func addNewWallet(){
        do{
            try bip32KS!.createNewChildAccount(password: Strings().password)
        }catch{
            print("Debug: There is a problem while creating bip32ks child account")
            print(error)
        }
        saveBIP32Key()
    }
    
    private func saveBIP32Key() {
        do{
            let keydata = try JSONEncoder().encode(bip32KS!.keystoreParams)
            FileManager.default.createFile(atPath: appDir + "/bip32_keystore"+"/key.json", contents: keydata, attributes: nil)
        }catch{
            print("Debug: There is a problem while saving bip32 keystore")
            print(error)
        }
    }
    
    func getEtherBalance(addr: EthereumAddress) -> String{
        if let bal = web3Net?.eth.getBalance(address: addr){
            let balString = Web3Utils.formatToEthereumUnits(bal.value!)
            return balString!
        }else{
            return ""
        }
    }
    func sentEther(fromAddr:String, toAddr : String, amount : String){
        let etherABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
        print("Debug: coldWalletABI \(etherABI)")
        print("-----------------------------------------------------------")
        
        let toAddress = EthereumAddress(toAddr)!
        print("Debug: coldWalletAddress \(toAddress)")
        print("-----------------------------------------------------------")
        
        var options = Web3Options.defaultOptions()
        print("Debug: options \(options)")
        print("-----------------------------------------------------------")
        
        let gasPriceResult = web3Net?.eth.getGasPrice()
        print("Debug: gasPriceResult \(String(describing: gasPriceResult))")
        print("-----------------------------------------------------------")
        guard case .success(let gasPrice)? = gasPriceResult else {return}
        options.gasPrice = gasPrice
        print("Debug: gasPrice \(gasPrice)")
        print("-----------------------------------------------------------")
        
        options.value = Web3Utils.parseToBigUInt(amount, units: Web3.Utils.Units.eth)
        print("Debug: options.value \(String(describing: options.value))")
        print("-----------------------------------------------------------")
        
        options.from = EthereumAddress(fromAddr)!
        print("Debug: from \(String(describing: options.from))")
        print("-----------------------------------------------------------")
        
        let estimatedGasResult = web3Net?.contract(etherABI, at: toAddress)!.method(options: options)!.estimateGas(options: nil)
        print("Debug: estimatedGasResult \(String(describing: estimatedGasResult))")
        print("-----------------------------------------------------------")
        guard case .success(let estimatedGas)? = estimatedGasResult else {return}
        options.gasLimit = estimatedGas
        print("Debug: gasLimit \(String(describing: options.gasLimit))")
        print("-----------------------------------------------------------")
        
        let intermediateSend = web3Net?.contract(etherABI, at: toAddress, abiVersion: 2)!.method(options: options)!
        let sendResultBip32 = intermediateSend?.send(password: Strings().password)
        print("Debug: sendResultBip32 \(String(describing: sendResultBip32))")
        print("-----------------------------------------------------------")
        
        switch sendResultBip32 {
        case .success(let r)?:
            print("Debug : Send Success")
            print(r)
        case .failure(let err)?:
            print("Debug : Send Error")
            print(err)
        case .none:
            print("Debug : Send Error")
            print("Return nothing")
        }
    }
}

//MARK: - Ethereum Token Handling
extension EthWalletManager{
    func getCustomTokenName(addr: String) -> String{
        if let customToken = web3Net?.contract(Web3.Utils.erc20ABI, at: EthereumAddress(addr)!, abiVersion: 2){
            
            print("Debug: Add custom token contract \(customToken)")
            
            let gasPriceResult = web3Net?.eth.getGasPrice()
            guard case .success(let gasPrice)? = gasPriceResult else {return ""}
            var options = Web3Options.defaultOptions()
            options.gasPrice = gasPrice
            options.from = EthereumAddress(addr)!
            
            guard let tokenNameResult = customToken.method("name", parameters: [] as [AnyObject], options: options)?.call(options: nil) else {return ""}
            
            print("Debug: Add custom token result \(tokenNameResult)")
            
            guard case .success(let nameResult) = tokenNameResult, let tokenName = nameResult["0"] as? String else {return ""}
            
            return tokenName
        }
        return ""
    }
    func getTokenBalance(tokenAddress: String, ownerAddress: String) -> String{
        if let customToken = web3Net?.contract(Web3.Utils.erc20ABI, at: EthereumAddress(tokenAddress)!, abiVersion: 2){
            
            print("Debug: Add custom token contract \(customToken)")
            
            let gasPriceResult = web3Net?.eth.getGasPrice()
            guard case .success(let gasPrice)? = gasPriceResult else {return ""}
            var options = Web3Options.defaultOptions()
            options.gasPrice = gasPrice
            options.from = EthereumAddress(tokenAddress)!
            
            guard let tokenBalanceResult = customToken.method("balanceOf", parameters: [EthereumAddress(ownerAddress)] as [AnyObject], options: options)?.call(options: nil) else {return ""}
            
            print("Debug: Add custom token result \(tokenBalanceResult)")
            
            guard case .success(let balanceResult) = tokenBalanceResult, let tokenBalance = balanceResult["0"] as? BigUInt else {return ""}
            return String(tokenBalance)
        }
        return ""
    }
    func sendToken(fromAddr : String, toAddr : String, contractAddr : String, amount: String){
        
        var tokenTransferOptions = Web3Options.defaultOptions()
        let gasPriceResult = web3Net?.eth.getGasPrice()
        guard case .success(let gasPrice)? = gasPriceResult else {return}
        tokenTransferOptions.gasPrice = gasPrice
        tokenTransferOptions.from = EthereumAddress(fromAddr)!
        
        
        let testToken = web3Net?.contract(Web3.Utils.erc20ABI, at: EthereumAddress(contractAddr)!, abiVersion: 2)!
        
        
        let amt = BigUInt(amount)
        print(amt)
        let intermediateForTokenTransfer = testToken?.method("transfer", parameters: [EthereumAddress(toAddr)!, amt!] as [AnyObject], options: tokenTransferOptions)!
        let gasEstimateResult = intermediateForTokenTransfer?.estimateGas(options: nil)
        guard case .success(let gasEstimate)? = gasEstimateResult else {return}
        var optionsWithCustomGasLimit = Web3Options()
        optionsWithCustomGasLimit.gasLimit = gasEstimate
        let tokenTransferResult = intermediateForTokenTransfer?.send(password: Strings().password, options: optionsWithCustomGasLimit)
        switch tokenTransferResult {
        case .success(let res)?:
            print("Token transfer successful")
            print(res)
        case .failure(let error)?:
            print(error)
        case .none:
            print("error")
        }
        
    }
}
