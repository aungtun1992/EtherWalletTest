//
//  WalletDetailViewController.swift
//  etherWalletTest
//
//  Created by Activate on 18/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit
import web3swift

class WalletDetailViewController: UIViewController {
    @IBOutlet weak var CoinNameTitle: UINavigationItem!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    var ethWM : EthWalletManager?
    var coinName : String = ""
    var address : String = ""
    var walletType = WalletTypes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        addressLabel.text = address
        CoinNameTitle.title = coinName
        
        if let _ethWM = ethWM {
            if walletType.coinDetails.keys.contains(coinName){
                if let coldWalletAddress = EthereumAddress(address){
                    let bal = _ethWM.getEtherBalance(addr: coldWalletAddress)
                    balanceLabel.text = bal + " ETH"
                }
                else{
                    balanceLabel.text = "0 ETH"
                }
            }
            else if walletType.tokenDetails.keys.contains(coinName){
                let tokenDetail = walletType.tokenDetails[coinName]
                let bal = _ethWM.getTokenBalance(tokenAddress: (tokenDetail?.tokenAddress)!, ownerAddress: address)
                balanceLabel.text = bal
            }
        }else{
            fatalError()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToSendDetail", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SendDetialViewController
        destinationVC.ethWM = ethWM
        destinationVC.fromAddress = address
        destinationVC.coinName = coinName
    }
    

}
