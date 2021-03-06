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
        //MARK: - Observer for Keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(AddCustomCoinViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddCustomCoinViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - What to do when keyboard showup
    //---------------------------------------------------------------------------------------------
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= (keyboardSize.height + 25)
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += (keyboardSize.height + 25)
            }
        }
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
        //tableVC.mnemonicWords = mnemonicInput.text!
        tableVC.ethWM = ethWM
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
}
