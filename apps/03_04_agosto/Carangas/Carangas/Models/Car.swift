//
//  Car.swift
//  Carangas
//
//  Created by Douglas Frari on 03/08/18.
//  Copyright © 2018 CESAR School. All rights reserved.
//

import Foundation

class Car: Codable {
    
    var _id: String?
    var brand: String = "" // marca
    var gasType: Int = 0
    var name: String = ""
    var price: Double = 0.0
    
    var gas: String {
        switch gasType {
        case 0:
            return "Flex"
        case 1:
            return "Álcool"
        default:
            return "Gasolina"
        }
    }
}

struct Brand: Codable {
    let fipe_name: String
}
