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
import RealmSwift

class WalletTableViewController: UITableViewController{

    @IBOutlet var walletTableView: UITableView!
    
    let realm = try! Realm()
    
    var mnemonicWords : String?
    var ethWM : EthWalletManager?
    //var cachedAccounts: [WalletData] = [WalletData]()
    var cachedWalletsInRealm : Results<WalletData>?
    
    var strings = Strings()
    
    var refresher : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walletTableView.separatorStyle = .none
        walletTableView.rowHeight = 90
        walletTableView.estimatedRowHeight = 120.0
        walletTableView.register(UINib(nibName: "WalletTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomWalletCell")
        
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(WalletTableViewController.updateCachedDataFromEthereum), for: UIControlEvents.valueChanged)
        walletTableView.addSubview(refresher)
        
        loadCachedRealmData()
        updateCachedDataFromEthereum()
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
        print("Debug: cached acccounts size \(String(describing: cachedWalletsInRealm?.count))")
        return cachedWalletsInRealm?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomWalletCell", for: indexPath) as! WalletTableViewCell
        
        if let walletData = cachedWalletsInRealm?[indexPath.row]{
            cell.coinName.text = walletData.type
            cell.coinAddress.text = walletData.address
            cell.coinAmount.text = walletData.balance + "ETH"
        }
        cell.coinSymbol.image = UIImage(named: "EthereumIcon")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetailView", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToDetailView"){
            let destinationVC = segue.destination as! WalletDetailViewController
            if let indexPath = walletTableView.indexPathForSelectedRow {
                destinationVC.address = cachedWalletsInRealm![indexPath.row].address
                destinationVC.coinType = cachedWalletsInRealm![indexPath.row].type
            }
            destinationVC.ethWM = self.ethWM
        }
    }
    
    @objc func updateCachedDataFromEthereum(){
        
        //ellaborate way to check the address
        //Reason, add account will rearrage the order
        if let _ethWM = ethWM {
            _ethWM.bip32KSManager.addresses?.forEach({ (web3AccountAddress) in
                print("Debug: Existing Address in AccManager - \(web3AccountAddress.address)")
                var exist = false
                if let cachedWallets = cachedWalletsInRealm {
                    for index in 0..<cachedWallets.count{
                        print("Debug: Existing Address in CachedWallet - \(cachedWallets[index].address)")
                        if(cachedWallets[index].address == web3AccountAddress.address){
                            print("Debug: They are the same")
                            exist = true
                            let bal = _ethWM.web3Net?.eth.getBalance(address: web3AccountAddress)
                            let balString = Web3Utils.formatToEthereumUnits((bal!.value)!)
                            print("Debug: Updated the balance \(cachedWallets[index].balance) to \(String(describing: balString!))")
                            //cachedWallets[index].balance = balString!
                            do{
                                try realm.write{
                                    cachedWallets[index].balance = balString!
                                }
                            }
                            catch{
                                print("Debug: Error saving New Balance , \(error)")
                            }
                            
                            return;
                        }
                    }
                    if(exist == false){
                        print("Debug: They are NOT the same")
                        
                        let type = "Ethereum"
                        let addr = web3AccountAddress.address
                        let bal = _ethWM.web3Net?.eth.getBalance(address: web3AccountAddress)
                        let balString = Web3Utils.formatToEthereumUnits((bal!.value)!)
                        
                        print("Debug: Adding the new data to the realm")
                        
                        let newWallet = WalletData()
                        newWallet.type = type
                        newWallet.address = addr
                        newWallet.balance = balString!
                        addNewCachedWalletData(walletData: newWallet)
                    }
                    print("------------------------------------------------------------------")
                }
            })
        }
        walletTableView.reloadData()
        refresher.endRefreshing()
    }
    func addNewCachedWalletData(walletData : WalletData){
        do{
            try realm.write{
                realm.add(walletData)
            }
        }
        catch{
            print("Error saving context \(error)")
        }
        walletTableView.reloadData()
    }
    func loadCachedRealmData(){
        cachedWalletsInRealm = realm.objects(WalletData.self)
    }
    
    @IBAction func addWallet(_ sender: Any) {
        ethWM?.addNewWallet()
        updateCachedDataFromEthereum()
        walletTableView.reloadData()
    }
}
