//
//  RESTAlamofire.swift
//  Carangas
//
//  Created by Douglas Frari on 04/08/18.
//  Copyright © 2018 Eric Brito. All rights reserved.
//

import Foundation
import Alamofire



class RESTAlamofire {
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    private static let urlFipe = "https://fipeapi.appspot.com/api/1/carros/marcas.json"
    
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type":"application/json"]
        config.timeoutIntervalForRequest = 10.0
        config.httpMaximumConnectionsPerHost = 5
        return config
    }()
    
    private static let session = URLSession(configuration: configuration)
    
    
    class func loadCarsAlamofire(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void) {
        
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
        }
        
        Alamofire.request(url, method: .get)
            .validate()
            .responseJSON { response in
                
                guard response.result.isSuccess else {
                    onError(.noData)
                    return
                }
                
                // servidor respondeu com sucesso :)
                // obter o valor de data
                guard let data = response.data else {
                    onError(.noData)
                    return
                }
                
                do {
                    let cars = try JSONDecoder().decode([Car].self, from: data)
                    onComplete(cars)
                    
                } catch {
                    // algum erro ocorreu com os dados
                    print(error.localizedDescription)
                    onError(.invalidJSON)
                }
        }
        
    }
}


