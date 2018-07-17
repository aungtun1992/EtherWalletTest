//
//  mnemonicViewController.swift
//  etherWalletTest
//
//  Created by Activate on 15/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit
import web3swift
import SVProgressHUD

class CreateMnemonicViewController: UIViewController {

    @IBOutlet weak var mnemoniclabel: UILabel!
    
    var ethWM: EthWalletManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateMnemonicWords()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Functions For Generating Mnemonic Words
    //---------------------------------------------------------------------------------------------
    func generateMnemonicWords()
    {
        let language: BIP39Language = .english
        var mnemonic : String?
        do {
            mnemonic = try (BIP39.generateMnemonics(bitsOfEntropy: 128, language: language))
        } catch {
            mnemonic = ""
            print(error)
        }
        mnemoniclabel.text = mnemonic
    }
    
    //MARK: - Functions for Button Press
    //---------------------------------------------------------------------------------------------
    @IBAction func walletPressed(_ sender: Any) {
        SVProgressHUD.show()
        ethWM = EthWalletManager.init(mnemonicWords: mnemoniclabel.text!)
        performSegue(withIdentifier: "mnemonicGoToWallet", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Debug: it is preparing for segue to wallet table view from menmonic view")
        let navigationVC = segue.destination as! UINavigationController
        let tableVC = navigationVC.viewControllers.first as! WalletTableViewController
        tableVC.mnemonicWords = mnemoniclabel.text
        tableVC.ethWM = ethWM
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
}
