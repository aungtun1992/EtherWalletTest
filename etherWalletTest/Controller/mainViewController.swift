//
//  ViewController.swift
//  etherWalletTest
//
//  Created by Activate on 15/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit
import SVProgressHUD
class mainViewController: UIViewController {

    //initialize ether wallete manager
    //var ethWM = EthWalletManager()
    var ethWM : EthWalletManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ethWM = EthWalletManager()
    }
    override func viewWillAppear(_ animated: Bool) {
        SVProgressHUD.show()
    }
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    override func viewDidAppear(_ animated: Bool) {
        //If there is keystore Straight go to wallet Page
        if ethWM!.ksExist {
            performSegue(withIdentifier: "MainGoToWallet", sender: self)
        }else{
            performSegue(withIdentifier: "MainGoToCreate", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //If Going straight to keystore => Pass along the ether wallet manager
        if segue.identifier == "MainGoToWallet"{
            let navigationVC = segue.destination as! UINavigationController
            let tableVC = navigationVC.viewControllers.first as! WalletTableViewController
            tableVC.ethWM = self.ethWM
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

