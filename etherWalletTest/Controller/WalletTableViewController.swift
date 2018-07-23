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
    
    // MARK: - Local Variables
    //---------------------------------------------------------------------------------------------
    let realm = try! Realm()
    var uiRefresher : UIRefreshControl!
    var ethWM : EthWalletManager?
    var cachedCoinData : Results<CoinData>?
    var cachedTokenData : Results<TokenData>?
    var walletType = WalletTypes()
    
    // MARK: - View Initial Loading
    //---------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Table Styling Setup
        //---------------------------------------------------------------------------------------------
        walletTableView.separatorStyle = .none
        walletTableView.rowHeight = 90
        walletTableView.estimatedRowHeight = 120.0
        walletTableView.register(UINib(nibName: "WalletTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomWalletCell")
        
        // MARK: - Pull to refresh Setup
        //---------------------------------------------------------------------------------------------
        uiRefresher = UIRefreshControl()
        uiRefresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        uiRefresher.addTarget(self, action: #selector(WalletTableViewController.updateCachedCoinData), for: UIControlEvents.valueChanged)
        walletTableView.addSubview(uiRefresher)
        
        //Load Persisting data to Local Cache
        loadCoinData()
        loadTokenData()
        //Update Local Cache and Save on Realm
        updateCachedCoinData()
        updateErc20CoinBalances()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    //---------------------------------------------------------------------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Debug: cached acccounts size \(String(describing: cachedCoinData?.count))")
        return (cachedCoinData?.count ?? 0) + (walletType.tokensInRealm?.count ?? 0)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomWalletCell", for: indexPath) as! WalletTableViewCell
        if let coinData = cachedCoinData{
            if indexPath.row < coinData.count{
                cell.coinName.text = coinData[indexPath.row].name
                cell.coinAddress.text = coinData[indexPath.row].address
                cell.coinAmount.text = coinData[indexPath.row].balance + "ETH"
                let imageName = walletType.coinDetails[coinData[indexPath.row].name]?.imageName ?? "default"
                cell.coinSymbol.image = UIImage(named: imageName)
            }
            else{
                if let tokenData = walletType.tokensInRealm {
                    let index = indexPath.row - coinData.count
                    cell.coinName.text = tokenData[index].name
                    cell.coinAddress.text = tokenData[index].ownerAddr[0].address
                    cell.coinAmount.text = tokenData[index].balance
                    let imageName = walletType.tokenDetails[tokenData[index].name]?.imageName ?? "default"
                    cell.coinSymbol.image = UIImage(named: imageName)
                }
            }
        }
        return cell
    }
    
    // MARK: - UI Interaction
    //---------------------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetailView", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    @IBAction func addWallet(_ sender: Any) {
        performSegue(withIdentifier: "goToCoinTypes", sender: self)
    }
    
    // MARK: - Model/Database Manipulation
    //---------------------------------------------------------------------------------------------
    
    @objc func updateCachedCoinData(){
        updateEtherBalances()
        updateErc20CoinBalances()
        walletTableView.reloadData()
        uiRefresher.endRefreshing()
    }
    //Updating balacne for Ethereum only
    func updateEtherBalances(){
        if let _ethWM = ethWM{
            _ethWM.bip32KSManager.addresses?.forEach({ (etherAddress) in
                if let coinData = cachedCoinData?.filter("name =[cd] %@ AND address =[cd] %@ ", "Ethereum", etherAddress.address){
                    if coinData.count < 1{
                        let newCoinData = CoinData()
                        newCoinData.name = "Ethereum"
                        newCoinData.address = etherAddress.address
                        newCoinData.balance = _ethWM.getEtherBalance(addr: etherAddress)
                        addNewCoinData(coinData: newCoinData)
                    }else{
                        print("Debug: \(etherAddress.address) already exist thus updating balance")
                        print("Debug: there are \(coinData.count) coinData with \(etherAddress.address)")
                        let balance = _ethWM.getEtherBalance(addr: etherAddress)
                        updateCoinDataBalance(coinData: coinData[0], amt: balance)
                    }
                }else{
                    print("Debug: There is a problem with filtering cachedCoinData")
                }
            })
        }
    }
    func updateErc20CoinBalances(){
        if let _ethWM = ethWM{
            if let ERC20Tokens = cachedTokenData?.filter("type =[cd] %@", "ERC20"){
                if(ERC20Tokens.count > 0){
                    ERC20Tokens.forEach({ (erc20Token) in
                        let balance = _ethWM.getTokenBalance(tokenAddress: erc20Token.tokenAddress, ownerAddress: (erc20Token.ownerAddr.first?.address)!)
                        updateTokenDataBalance(tokenData: erc20Token, amt: balance)
                    })
                }
            }else{
                print("Debug: There is a problem with filtering cachedTokenData")
            }
        }
    }
    
    //Realm Loading
    func loadCoinData(){
        cachedCoinData = realm.objects(CoinData.self)
    }
    func loadTokenData(){
        cachedTokenData = realm.objects(TokenData.self)
    }
    //Realm Adding
    func addNewCoinData(coinData : CoinData){
        do{
            try realm.write{
                realm.add(coinData)
            }
        }
        catch{
            print("Error adding new coin data \(error)")
        }
        walletTableView.reloadData()
    }
    func addNewTokenData(tokenData : TokenData){
        do{
            try realm.write{
                realm.add(tokenData)
            }
        }
        catch{
            print("Error adding new token data \(error)")
        }
        walletTableView.reloadData()
    }
    //Realm Updating
    func updateCoinDataBalance(coinData: CoinData, amt: String){
        do{
            try realm.write{
                coinData.balance = amt
            }
        }
        catch{
            print("Debug: Error updating existing coin balance , \(error)")
        }
    }
    func updateTokenDataBalance(tokenData : TokenData, amt: String){
        do{
            try realm.write{
                tokenData.balance = amt
            }
        }
        catch{
            print("Debug: Error updating existing token balance , \(error)")
        }
    }
    
}

// MARK: - Adding wallet actions / Handle Delete gate from Adding Wallet
//---------------------------------------------------------------------------------------------
extension WalletTableViewController :  handleWalletTypeSelection{
    func selectedWalletIsToken(token: Token) {
        if token.type == "ERC20"{
            if let etherCoinData = cachedCoinData?.filter("name =[cd] %@", "Ethereum"){
                if etherCoinData.count < 1{
                    addEthereumWallet()
                    selectedWalletIsToken(token: token)
                }else{
                    for i in 0..<etherCoinData.count{
                        let currentCoinToken = etherCoinData[i].tokens.filter("tokenAddress = %@", token.tokenAddress)
                        if currentCoinToken.count < 1 {
                            do{
                                try self.realm.write {
                                    let newTokenData = TokenData()
                                    newTokenData.name = token.name
                                    newTokenData.type = token.type
                                    newTokenData.tokenAddress = token.tokenAddress
                                    etherCoinData[i].tokens.append(newTokenData)
                                    self.realm.add(newTokenData)
                                }
                            }catch{
                                print("Error saving to realm \(error)")
                            }
                            break
                        }
                    }
                }
            }else{
                print("Debug: There is a problem with filtering cachedCoinData")
            }
        }
    }
    
    func selectedWalletIsCoin(type: Coin) {
        if type.name == "Ethereum" {
            addEthereumWallet()
        }
    }
    
    // MARK: - Add Ethereum
    //---------------------------------------------------------------------------------------------
    func addEthereumWallet(){
        //Ask Ether Wallet Manager to add new index wallet
        //Then Update The local persistant data
        ethWM?.addNewWallet()
        updateCachedCoinData()
        walletTableView.reloadData()
    }
}

// MARK: - Segue Preparation Decisions
//---------------------------------------------------------------------------------------------
extension WalletTableViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToDetailView"){
            let destinationVC = segue.destination as! WalletDetailViewController
            if let indexPath = walletTableView.indexPathForSelectedRow {
                destinationVC.address = cachedCoinData![indexPath.row].address
                destinationVC.coinName = cachedCoinData![indexPath.row].name
            }
            destinationVC.ethWM = self.ethWM
        }
        else if segue.identifier == "goToCoinTypes" {
            let destinationVC = segue.destination as! AddNewWalletTableViewController
            destinationVC.ethWM = self.ethWM
            destinationVC.delegate = self
        }
    }
}
