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
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var places: [Place]!
    
    // para guardar os pontos de interesse (POI) encontrados no search
    var poi: [MKAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // esconder os componentes
        searchBar.isHidden = true
        viInfo.isHidden = true
        
        // definindo programaticamente o Type do mapa
        mapView.mapType = .mutedStandard
        
        // para permitir alterar a annotation mostrada na view do mapa
        mapView.delegate = self
        
        // configura o título
        if places.count == 1 {
            title = places[0].name
        } else {
            title = "Meus lugares"
        }
        
        for place in places {
            addMap(place)
        }
        
        showPlaces()
    }
    
    func addMap(_ place: Place) {
        print("Place -> \(place.name)")
        places.append(place)
        
        // usando Annotations
        //let annotation = MKPointAnnotation()
        
        // usando PlaceAnnotation do nosso model
        let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
        annotation.address = place.address
        annotation.coordinate = place.coordinate // variavel computada
        annotation.title = place.name
        mapView.addAnnotation(annotation)
    }
    
    func showPlaces() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
     
    @IBAction func showRoute(_ sender: UIButton) {
    }
    
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        self.searchBar.resignFirstResponder()
        self.searchBar.isHidden = !self.searchBar.isHidden
    }
   
}


extension MapViewController: MKMapViewDelegate {
    
    // usado para recuperar uma annotationView para permitir modifica-la
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is PlaceAnnotation) {
            // mantem o default caso nao seja o tipo esperado.
            return nil
        }
        let placeAnnotation = annotation as! PlaceAnnotation
        let type = placeAnnotation.type
        let identifier = "\(type)"
        // tentando reusar uma view do pino padrao (MKMarkerAnnotationView)
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            // criando pela primeira vez uma annotation view
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true // informacoes extras na forma de um balao
        // usando Point of Interess
        annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "poi")
        annotationView?.glyphImage = type == .place ?  #imageLiteral(resourceName: "placeGlyph") :  #imageLiteral(resourceName: "poiGlyph")
        annotationView?.displayPriority = type == .place ? .required : .defaultHigh
        
        return annotationView
    }
}

extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        // começa animação do loading
        loading.startAnimating()
        
        // prepara uma busca em pontos de interesse do mapa
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        
        // em qual regiao será realizado a pesquisa
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                guard let response = response else {
                    DispatchQueue.main.async {
                        self.loading.stopAnimating()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    // remove as ultimas buscas adicionadas no array de POI
                    self.mapView.removeAnnotations(self.poi)
                    self.poi.removeAll()
                    
                    // pega as respostas da busca e cria annotations
                    for item in response.mapItems {
                        let annotation = PlaceAnnotation(coordinate: item.placemark.coordinate, type: .poi)
                        annotation.title = item.name
                        annotation.subtitle = item.phoneNumber
                        annotation.address = Place.getFormattedAddress(with: item.placemark)
                        // atualizar a estrutura de POI
                        self.poi.append(annotation)
                    }
                    // atualizar o mapa com as annotations encontradas e mostrar no mapa
                    self.mapView.addAnnotations(self.poi)
                    self.mapView.showAnnotations(self.poi, animated: true)
                }
                
            } else {
                print(error.debugDescription)
            }
            
            DispatchQueue.main.async {
                self.loading.stopAnimating()
            }
        }
        
    }
    
}


