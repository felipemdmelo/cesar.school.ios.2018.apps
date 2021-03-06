//
//  CarsTableViewController.swift
//  Carangas
//
//  Created by Eric Brito on 21/10/17.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit
import SideMenu

class CarsTableViewController: UITableViewController {

    var cars: [Car] = []
    
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(named: "main")
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadCars), for: .valueChanged)
        
        
        // Define the menus
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadCars()
    }
    

   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // TODO como mostrar sem dados na tela de forma ideal ?
        
        return cars.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        let car = cars[indexPath.row]
        cell.textLabel?.text = car.name
        cell.detailTextLabel?.text = car.brand

        return cell
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
        
            let car = cars[indexPath.row]
            REST.delete(car: car) { (success) in
                if success {
                    
                    // ATENCAO nao esquecer disso
                    self.cars.remove(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        // Delete the row from the data source
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }

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
        
        if segue.identifier == "viewSegue" {
            let vc = segue.destination as! CarViewController
            vc.car = cars[tableView.indexPathForSelectedRow!.row]
        }
        
    }
    
    @objc fileprivate func loadCars() {
        
        
        RESTAlamofire.loadCarsAlamofire(onComplete: { (cars) in
            
            self.cars = cars
            
            // precisa recarregar a tableview usando a main UI thread
            DispatchQueue.main.async {
                
                self.tableView.refreshControl?.endRefreshing()
                
                if cars.count == 0 {
                    // mostrar mensagem padrao
                    self.label.text = "Sem dados"
                    self.tableView.backgroundView = self.label
                } else {
                    self.label.text = ""
                }
                
                
                
                self.tableView.reloadData()
            }
            
        }) { (error) in
            // algum erro ocorreu no request
            
            var response: String = ""
            
            switch error {
                case .invalidJSON:
                    response = "invalidJSON"
                case .noData:
                    response = "noData"
                case .noResponse:
                    response = "noResponse"
                case .url:
                    response = "JSON inválido"
                case .taskError(let error):
                    response = "\(error.localizedDescription)"
                case .responseStatusCode(let code):
                    if code != 200 {
                        response = "Algum problema com o servidor. :( \nError:\(code)"
                    }
            }
            
            print(response)
            
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
        }

/*
        REST.loadCars(onComplete: { (cars) in
            
            self.cars = cars
            
            // precisa recarregar a tableview usando a main UI thread
            DispatchQueue.main.async {
            
                self.tableView.refreshControl?.endRefreshing()
                
                if cars.count == 0 {
                    // mostrar mensagem padrao
                    self.label.text = "Sem dados"
                    self.tableView.backgroundView = self.label
                } else {
                    self.label.text = ""
                }
                
                
                
                self.tableView.reloadData()
            }
            
        }) { (error) in
            
            
            
            // algum erro ocorreu no request
            
            var response: String = ""
            
            switch error {
            case .invalidJSON:
                response = "invalidJSON"
            case .noData:
                response = "noData"
            case .noResponse:
                response = "noResponse"
            case .url:
                response = "JSON inválido"
            case .taskError(let error):
                response = "\(error.localizedDescription)"
            case .responseStatusCode(let code):
                if code != 200 {
                    response = "Algum problema com o servidor. :( \nError:\(code)"
                }
            }
            
            print(response)
            
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
        }
*/
        
    }
    

}
