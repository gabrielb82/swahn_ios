//
//  Warehouse.swift
//  SwahnTaubate
//
//  Created by Gabriel Barbosa on 21/11/18.
//

import UIKit
import CoreLocation

struct WarehouseSet {
    var name:Warehouse
    var location:CLLocation
    var radius:CGFloat
}

struct WarehouseCoordinate {
    static var Patio = CLLocation(latitude: -23.054458, longitude: -45.631510)
    static var Portaria = CLLocation(latitude: -23.055665, longitude:-45.632015)
    static var Recebimento1 = CLLocation(latitude: -23.056023,longitude: -45.635110)
    static var Recebimento2 = CLLocation(latitude: -23.058431, longitude:-45.635153)
    static var Recebimento3 = CLLocation(latitude: -23.061619,longitude: -45.636191)
    static var Inflamavel = CLLocation(latitude: -23.055188, longitude:-45.637902)
    static var Vasilhame = CLLocation(latitude: -23.053722,longitude: -45.635965)
    static var PatioBalanca = CLLocation(latitude: -23.055248,longitude: -45.632829)
    
}

enum Warehouse {
    case Patio
    case Portaria
    case Recebimento1
    case Recebimento2
    case Recebimento3
    case Inflamavel
    case Vasilhame
    case NoWhere
    case PatioBalanca
}
