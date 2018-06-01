//
//  PlaceFinderViewController.swift
//  QueroConhecer
//
//  Created by Douglas Frari on 30/05/2018.
//  Copyright © 2018 CESAR School. All rights reserved.
//

import UIKit
import MapKit

// repassa o Place escolhido para a tela principal
protocol PlaceFinderDelegate: class {
    func addPlace(_ place: Place)
}

class PlaceFinderViewController: UIViewController {

    // para indicar tipo da mensagem a ser exibida no alerta
    enum PlaceFinderMessageType {
        case error(String)
        case confirmation(String)
    }
    
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var viLoading: UIView!
    
    // lugar atual escolhido
    var place: Place!
    weak var delegate: PlaceFinderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // criar gestos de long press
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_:)))
        gesture.minimumPressDuration = 2.0 // 2 seconds
        mapView.addGestureRecognizer(gesture)
    }
    
    
    @objc func getLocation(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            load(show: true)
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                // placemarks - Contains an array of CLPlacemark objects.
                self.loadPoint(error, placemarks)
            }
        }
    }

    func loadPoint(_ error: Error?, _ placemarks: [CLPlacemark]?) {
        self.load(show: false)
        if error == nil {
            if !self.savePlace(with: placemarks?.first) {
                self.showMessage(type: .error("Não foi encontrado nenhum local com esse nome"))
            }
        } else {
            self.showMessage(type: .error("Erro desconhecido"))
        }
    }
   
    @IBAction func findCity(_ sender: UIButton) {
        self.tfCity.resignFirstResponder()
        let address = tfCity.text!
        load(show: true)
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            self.loadPoint(error, placemarks)
        }
    }
    
    func savePlace(with placemark: CLPlacemark?) -> Bool {
        
        guard let placemark = placemark, let coordinate = placemark.location?.coordinate else {
            return false
        }
        
        // Nil-Coalescing Operator
        let name = placemark.name ?? placemark.country ?? "Desconhecido"
        let address = Place.getFormattedAddress(with: placemark)
        place = Place(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude, address: address)
        
        // para mostrar no mapa precisamos criar uma região para exibi-la
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 3500, 3500)
        mapView.setRegion(region, animated: true)
        
        self.showMessage(type: .confirmation(place.name))
        
        return true
    }
    
    func showMessage(type: PlaceFinderMessageType) {
     
        let title: String, message: String
        var hasConfirmation: Bool = false
        
        switch type {
            case .confirmation(let name):
                title = "Local encontrado"
                message = "Deseja adicionar \(name)?"
                hasConfirmation = true
            case .error(let errorMessage):
                title = "Erro"
                message = errorMessage
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if hasConfirmation {
            let confirmationAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // User confirmou action
                self.delegate?.addPlace(self.place)
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(confirmationAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func load(show: Bool) {
        viLoading.isHidden = !show
        if show {
            aiLoading.startAnimating()
        } else {
            aiLoading.stopAnimating()
        }
    }
    
    
}
