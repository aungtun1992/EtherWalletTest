//
//  AddCustomCoinViewController.swift
//  etherWalletTest
//
//  Created by Activate on 19/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit

protocol handleCustomTokenAddition {
    func addCustomToken(addr: String)
}

class AddCustomCoinViewController: UIViewController {

    @IBOutlet weak var blankArea: UIView!
    @IBOutlet weak var tokenAddress: UITextField!
    @IBOutlet weak var decimal: UITextField!
    
    var delegate : handleCustomTokenAddition?
    
    //MARK: - View Loading
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
    
    //MARK: - UI Interactions
    //---------------------------------------------------------------------------------------------
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view == blankArea {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addPressed(_ sender: Any) {
        delegate?.addCustomToken(addr: tokenAddress.text!)
        dismiss(animated: true, completion: nil)
    }
}
