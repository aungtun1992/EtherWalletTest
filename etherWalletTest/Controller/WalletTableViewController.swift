//
//  WalletTableViewController.swift
//  etherWalletTest
//
//  Created by Activate on 16/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit
import web3swift
import SVProgressHUD

class WalletTableViewController: UITableViewController{

    @IBOutlet var walletTableView: UITableView!
    
    var mnemonicWords : String?
    var ethWM : EthWalletManager?
    var cachedAccounts: [WalletData] = [WalletData]()

    var strings = Strings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walletTableView.separatorStyle = .none
        walletTableView.rowHeight = 90
        walletTableView.estimatedRowHeight = 120.0
        walletTableView.register(UINib(nibName: "WalletTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomWalletCell")
        reloadCachedData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("Debug: cached acccounts size \(cachedAccounts.count)")
        return cachedAccounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomWalletCell", for: indexPath) as! WalletTableViewCell
        
        cell.coinName.text = "Ethereum"
        cell.coinAddress.text = cachedAccounts[indexPath.row].address
        cell.coinAmount.text = cachedAccounts[indexPath.row].balance + "ETH"
        cell.coinSymbol.image = UIImage(named: "EthereumIcon")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetailView", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func reloadCachedData(){
        //ellaborate way to check the address
        //Reason, add account will rearrage the order
        if let _ethWM = ethWM {
            _ethWM.bip32KSManager.addresses?.forEach({ (newAddr) in
                var exist = false
                cachedAccounts.forEach({ (existingAddr) in
                    if(existingAddr.address == newAddr.address){
                        exist = true
                        let bal = _ethWM.web3Net?.eth.getBalance(address: newAddr)
                        let balString = Web3Utils.formatToEthereumUnits((bal!.value)!)
                        existingAddr.balance = balString!
                        return;
                    }
                })
                if(exist == false){
                    let type = "Ethereum"
                    let addr = newAddr.address
                    let bal = _ethWM.web3Net?.eth.getBalance(address: newAddr)
                    let balString = Web3Utils.formatToEthereumUnits((bal!.value)!)
                    let insertLocation = (cachedAccounts.count)
                    cachedAccounts.insert(WalletData(type: type, addr: addr, bal: balString!), at: insertLocation)
                }
            })
        }
    }
    
    @IBAction func addWallet(_ sender: Any) {
        ethWM?.addNewWallet()
        reloadCachedData()
        walletTableView.reloadData()
    }
    
}
