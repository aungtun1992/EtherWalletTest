//
//  ImportWalletViewController.swift
//  etherWalletTest
//
//  Created by Activate on 16/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit
import SVProgressHUD

class ImportWalletViewController: UIViewController {

    @IBOutlet weak var mnemonicInput: UITextView!
    
    var ethWM: EthWalletManager?
    var strings = Strings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Button Press Actions
    //---------------------------------------------------------------------------------------------

    @IBAction func importButtonPressed(_ sender: Any) {
        if(mnemonicInput.text.count<12){
            let alert = UIAlertController(title: strings.ErrMsgWrgPassphrase, message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default) { (action) in
            }
            alert.addAction(action)
            present(alert, animated: true)
        }
        else{
            SVProgressHUD.show()
            ethWM = EthWalletManager.init(mnemonicWords: mnemonicInput.text!)
            performSegue(withIdentifier: "importGoToWallet", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Debug: it is preparing for segue to wallet table view from import view")
        let navigationVC = segue.destination as! UINavigationController
        let tableVC = navigationVC.viewControllers.first as! WalletTableViewController
        tableVC.mnemonicWords = mnemonicInput.text!
        tableVC.ethWM = ethWM
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
}
