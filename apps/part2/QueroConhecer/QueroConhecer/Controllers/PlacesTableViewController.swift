//
//  PlacesTableViewController.swift
//  QueroConhecer
//
//  Created by Douglas Frari on 30/05/18.
//  Copyright © 2018 CESAR School. All rights reserved.
//

import UIKit

class PlacesTableViewController: UITableViewController {

    // estrutura para armazenar os Places
    var places: [Place] = []
    
    // persistence
    let ud = UserDefaults.standard
    
    // label com mensagem sem dados
    var lbNoPlaces: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPlaces()
        
        lbNoPlaces = UILabel()
        lbNoPlaces.text = "Cadastre os locais que deseja conhecer\nclicando no botão + acima."
        lbNoPlaces.textAlignment = .center
        lbNoPlaces.numberOfLines = 0
    }
    
    func loadPlaces() {
        
        if let placeData = ud.data(forKey: "places") {
            do {
                places = try JSONDecoder().decode([Place].self, from: placeData)
                tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func savePlaces() {
        do {
            let json = try JSONEncoder().encode(places)
            self.ud.setValue(json, forKey: "places")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func showAll() {
        performSegue(withIdentifier: "mapSegue", sender: places)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        
        if places.count > 0 {
            let btShowAll = UIBarButtonItem(title: "Exibir todos", style: .plain, target: self, action: #selector(showAll))
            navigationItem.leftBarButtonItem = btShowAll
            tableView.backgroundView = nil
        } else {
            navigationItem.leftBarButtonItem = nil
            tableView.backgroundView = lbNoPlaces
        }
        
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        let place = places[indexPath.row]
        
        cell.textLabel?.text = place.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let place = places[indexPath.row]
        performSegue(withIdentifier: "mapSegue", sender: place)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            places.remove(at: indexPath.row)
            savePlaces()
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier! == "finderSegue" {
            let vc = segue.destination as! PlaceFinderViewController
            vc.delegate = self
        } else if segue.identifier! == "mapSegue" {
            print("-> map segue")
            let vc = segue.destination as! MapViewController
            switch sender {
            case let place as Place:
                vc.places = [place]
            default:
                vc.places = places
            }
        }
    }
}


extension PlacesTableViewController: PlaceFinderDelegate {
    
    func addPlace(_ place: Place) {
        
        // evita que um place (mesma longitude e latitude) seja adicionado
        // TIP. : ver regra no model de Place
        if !places.contains(place) {
            // save
            self.places.append(place)
            self.savePlaces()
            self.tableView.reloadData()
        }
    }
}






