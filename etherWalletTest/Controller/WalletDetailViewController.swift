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

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var CoinNameTitle: UINavigationItem!
    
    var ethWM : EthWalletManager?
    
    var coinName : String = ""
    var address : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        addressLabel.text = address
        CoinNameTitle.title = coinName
        
        if let _ethWM = ethWM {
            if let coldWalletAddress = EthereumAddress(address){
                let bal = _ethWM.web3Net?.eth.getBalance(address: coldWalletAddress)
                let balString = Web3Utils.formatToEthereumUnits((bal!.value)!)
                balanceLabel.text = balString! + " ETH"
            }
            else{
                balanceLabel.text = "0 ETH"
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
        destinationVC.address = address
    }
    

}
