//
//  PlaceFinderViewController.swift
//  QueroConhecer
//
//  Created by Douglas Frari on 30/05/2018.
//  Copyright © 2018 CESAR School. All rights reserved.
//

import UIKit
import MapKit

class PlaceFinderViewController: UIViewController {

    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var viLoading: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

   
    @IBAction func findCity(_ sender: UIButton) {
        
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
