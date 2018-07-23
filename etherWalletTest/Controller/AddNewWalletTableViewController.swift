//
//  AddNewWalletTableViewController.swift
//  etherWalletTest
//
//  Created by Activate on 19/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit
import RealmSwift
import web3swift
import BigInt
protocol handleWalletTypeSelection {
    func selectedWalletIsToken(token : Token)
    func selectedWalletIsCoin(type: Coin)
}

class AddNewWalletTableViewController: UITableViewController {
    
    @IBOutlet var coinTypeTableView: UITableView!
    
    // MARK: - Local Variables
    //---------------------------------------------------------------------------------------------
    var delegate : handleWalletTypeSelection?
    var walletType : WalletTypes = WalletTypes()
    var ethWM : EthWalletManager?
    var cachedCoinData : Results<CoinData>?
    
    // MARK: - View Initial Loading
    //---------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        cachedCoinData = realm.objects(CoinData.self)
        
        // MARK: - Table Styling Setup
        //---------------------------------------------------------------------------------------------
        coinTypeTableView.separatorStyle = .none
        coinTypeTableView.rowHeight = 90
        coinTypeTableView.estimatedRowHeight = 120.0
        coinTypeTableView.register(UINib(nibName: "CoinTypesTableViewCell", bundle: nil), forCellReuseIdentifier: "CoinTypesTableCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    //---------------------------------------------------------------------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the count for both coin and token
        return walletType.coinDetails.count + walletType.tokenDetails.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinTypesTableCell", for: indexPath) as! CoinTypesTableViewCell
        
        let coinTypeCount = walletType.coinDetails.count
        if(indexPath.row < coinTypeCount){
            let coinName = Array(walletType.coinDetails.keys.sorted())[indexPath.row]
            cell.coinTitle.text = coinName
            cell.coinLogo.image = UIImage(named: (walletType.coinDetails[coinName]?.imageName)!)
        }else{
            let tokenName = Array(walletType.tokenDetails.keys.sorted())[indexPath.row - coinTypeCount]
            cell.coinTitle.text = tokenName
            cell.coinLogo.image = UIImage(named: (walletType.tokenDetails[tokenName]?.imageName)!)
        }
        return cell
    }
    
    // MARK: - Table view Interaction
    //---------------------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if the text is in the coin type return coin type
        let cell = tableView.cellForRow(at: indexPath) as! CoinTypesTableViewCell
        
       
        if let coin = walletType.coinDetails[cell.coinTitle.text!]{
            print("Debug: Selected type is Coin Type")

            delegate?.selectedWalletIsCoin(type: coin)
        }else if let selectedToken = walletType.tokenDetails[cell.coinTitle.text!]{
            print("Debug: Selected type is Token Type")
            print("Debug: Selected token is \(selectedToken.name)")
           delegate?.selectedWalletIsToken(token: selectedToken)
        }else{
            print("Debug: Selected Coin is not in the list")
        }
        self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    
    
}

extension AddNewWalletTableViewController : handleCustomTokenAddition {
    
    @IBAction func addCustomCoinPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToAddCustomToken", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddCustomToken" {
            let destinationVC = segue.destination as! AddCustomCoinViewController
            destinationVC.delegate = self
        }
    }
    
    //delegate to handle custom coin
    func addCustomToken(addr: String) {
        print("Debug: Add custom token handler")
        if let _ethWM = ethWM {
            let tokenName = _ethWM.getCustomTokenName(addr: addr)
            print("Debug: Add custom tokenName \(tokenName)")
            walletType.addCustomToken(name: String(tokenName), tokenAddr: addr)
        }
        coinTypeTableView.reloadData()
    }
    
    
}
