//
//  ViewController.swift
//  DemoCloudKit
//
//  Created by Douglas Frari on 17/08/18.
//  Copyright © 2018 CESAR School. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        request()
    }

    func request(){
        saveToCloud("Teste 123" )
    }
    
    func saveToCloud(_ note: String) {
        let newNote = CKRecord(recordType: "Notes")
        newNote.setValue(note, forKey: "content")
        
        container.publicCloudDatabase.save(newNote) { (record, error) in
            guard record != nil else {
                print(error.debugDescription)
                return
            }
            print("saved record")
        }
        
    }
}

