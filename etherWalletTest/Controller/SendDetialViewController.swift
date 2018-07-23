//
//  SendDetialViewController.swift
//  etherWalletTest
//
//  Created by Activate on 18/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit
import web3swift
import Foundation
import BigInt
import QRCodeReader
import AVFoundation
class SendDetialViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    
    @IBOutlet weak var BlankArewa: UIView!
    @IBOutlet weak var toAddress: UITextField!
    @IBOutlet weak var amount: UITextField!
    
    var ethWM : EthWalletManager?
    var address : String = ""
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader                  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton         = true
            $0.preferredStatusBarStyle = .lightContent
            
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        return QRCodeReaderViewController(builder: builder)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SendDetialViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SendDetialViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        
        print("Debug: Pressed send")

        let coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
        print("Debug: coldWalletABI \(coldWalletABI)")
        print("-----------------------------------------------------------")

        let coldWalletAddress = EthereumAddress(toAddress.text!)!
        print("Debug: coldWalletAddress \(coldWalletAddress)")
        print("-----------------------------------------------------------")

        var options = Web3Options.defaultOptions()
        print("Debug: options \(options)")
        print("-----------------------------------------------------------")

        let gasPriceResult = ethWM?.web3Net?.eth.getGasPrice()
        print("Debug: gasPriceResult \(String(describing: gasPriceResult))")
        print("-----------------------------------------------------------")
        guard case .success(let gasPrice)? = gasPriceResult else {return}
        options.gasPrice = gasPrice
        print("Debug: gasPrice \(gasPrice)")
        print("-----------------------------------------------------------")


        options.value = Web3Utils.parseToBigUInt(amount.text!, units: Web3.Utils.Units.eth)
        print("Debug: options.value \(String(describing: options.value))")
        print("-----------------------------------------------------------")

        options.from = EthereumAddress(address)!
        print("Debug: from \(String(describing: options.from))")
        print("-----------------------------------------------------------")

        let estimatedGasResult = ethWM?.web3Net?.contract(coldWalletABI, at: coldWalletAddress)!.method(options: options)!.estimateGas(options: nil)
        print("Debug: estimatedGasResult \(String(describing: estimatedGasResult))")
        print("-----------------------------------------------------------")
        guard case .success(let estimatedGas)? = estimatedGasResult else {return}
        options.gasLimit = estimatedGas
        print("Debug: gasLimit \(String(describing: options.gasLimit))")
        print("-----------------------------------------------------------")

        let intermediateSend = ethWM?.web3Net?.contract(coldWalletABI, at: coldWalletAddress, abiVersion: 2)!.method(options: options)!
        let sendResultBip32 = intermediateSend?.send(password: Strings().password)
        print("Debug: sendResultBip32 \(String(describing: sendResultBip32))")
        print("-----------------------------------------------------------")

        switch sendResultBip32 {
            case .success(let r)?:
                print("Debug : Send Success")
                print(r)
            case .failure(let err)?:
                print("Debug : Send Error")
                print(err)
            case .none:
                print("Debug : Send Error")
                print("Return nothing")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scanQRPressed(_ sender: Any) {
        guard checkScanPermissions() else { return }
        
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate               = self
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let result = result {
                print("Completion with result: \(result.value) of type \(result.metadataType)")
            }
        }
        
        present(readerVC, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToScanQR"){
            
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view == BlankArewa {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - QRReader Delegates
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true) { [weak self] in
            let alert = UIAlertController(
                title: "QRCodeReader",
                message: String (format:"%@ (of type %@)", result.value, result.metadataType),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self?.present(alert, animated: true, completion: nil)
        }
    }
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capturing to: \(newCaptureDevice.device.localizedName)")
    }
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            present(alert, animated: true, completion: nil)
            return false
        }
    }
}
