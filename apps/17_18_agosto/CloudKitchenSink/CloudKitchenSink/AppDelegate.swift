//
//  AppDelegate.swift
//  CloudKitchenSink
//
//  Created by Guilherme Rambo on 05/03/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import UIKit
import CloudKit

extension UIViewController {
    
    var container: CKContainer {
        return CKContainer(identifier: "iCloud.school.cesar.apps.turma2018Container")
    }
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureCloudKit()
        
        return true
    }
    
    private func configureCloudKit() {
        let container = CKContainer(identifier: "iCloud.school.cesar.apps.turma2018Container")
        
        container.privateCloudDatabase.fetchAllRecordZones { zones, error in
            guard let zones = zones, error == nil else {
                // error handling magic
                print(error.debugDescription)
                return
            }
            
            print("I have these zones: \(zones)")
        }
    }


}

