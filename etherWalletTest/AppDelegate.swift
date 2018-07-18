//
//  AppDelegate.swift
//  etherWalletTest
//
//  Created by Activate on 15/7/18.
//  Copyright © 2018 Activate. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        print("Debug: \(Realm.Configuration.defaultConfiguration.fileURL!)")
        do{
            _ = try Realm()
        }catch{
            print("error loading relam, \(error)" )
        }
        return true
    }
    

}

