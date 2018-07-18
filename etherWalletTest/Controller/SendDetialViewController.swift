//
//  SendDetialViewController.swift
//  etherWalletTest
//
//  Created by Activate on 18/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit
import web3swift
import Foundation
import BigInt


class SendDetialViewController: UIViewController {

    @IBOutlet weak var BlankArewa: UIView!
    @IBOutlet weak var toAddress: UITextField!
    @IBOutlet weak var amount: UITextField!
    
    var ethWM : EthWalletManager?
    var address : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view == BlankArewa {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        print("Debug: Pressed send")
        
        let coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
        print("Debug: coldWalletABI \(coldWalletABI)")
        print("-----------------------------------------------------------")
        
        let coldWalletAddress = EthereumAddress(toAddress.text!)!
        print("Debug: coldWalletAddress \(coldWalletAddress)")
        print("-----------------------------------------------------------")

        var options = Web3Options.defaultOptions()
        print("Debug: options \(options)")
        print("-----------------------------------------------------------")

        let gasPriceResult = ethWM?.web3Net?.eth.getGasPrice()
        print("Debug: gasPriceResult \(String(describing: gasPriceResult))")
        print("-----------------------------------------------------------")
        guard case .success(let gasPrice)? = gasPriceResult else {return}
        options.gasPrice = gasPrice
        print("Debug: gasPrice \(gasPrice)")
        print("-----------------------------------------------------------")

        options.value = BigUInt(1000000000000000000)
        print("Debug: options.value \(String(describing: options.value))")
        print("-----------------------------------------------------------")
        
        options.from = EthereumAddress(address)!
        print("Debug: from \(String(describing: options.from))")
        print("-----------------------------------------------------------")
       
        let estimatedGasResult = ethWM?.web3Net?.contract(coldWalletABI, at: coldWalletAddress)!.method(options: options)!.estimateGas(options: nil)
        print("Debug: estimatedGasResult \(String(describing: estimatedGasResult))")
        print("-----------------------------------------------------------")
        guard case .success(let estimatedGas)? = estimatedGasResult else {return}
        options.gasLimit = estimatedGas
        print("Debug: gasLimit \(String(describing: options.gasLimit))")
        print("-----------------------------------------------------------")
        
        let intermediateSend = ethWM?.web3Net?.contract(coldWalletABI, at: coldWalletAddress, abiVersion: 2)!.method(options: options)!
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
