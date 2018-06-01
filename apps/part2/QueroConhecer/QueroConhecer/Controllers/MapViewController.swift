//
//  MapViewController.swift
//  QueroConhecer
//
//  Created by Douglas Frari on 31/05/18.
//  Copyright © 2018 CESAR School. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    
    var places: [Place]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for place in places {
            print(place.name)
        }
        
    }
    
     
    @IBAction func showRoute(_ sender: UIButton) {
    }
    
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
    }
    
    
    
}
