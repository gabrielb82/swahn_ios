//
//  CONSTS.swift
//  SwahnTaubate
//
//  Created by Gabriel Barbosa on 21/11/18.
//

import UIKit
import Firebase

class CONSTS {
    static var TIMETOGETLOCAL = 2
    static var TIMETOENTERINWAREHOUSE = 20
    static var DISTANCETOCONSIDER = 50.0
    static var NUMBEROFLOCATION = 20
    static var NUMBEROFSECONDSTOWAITTOCONSIDER = 30
    static var THRESHOLDTOCONSIDERWAREHOUSE = 55
    static var SENHA = "223"
    static var CENTEROFFACTORY = GeoPoint(latitude: -23.058268, longitude: -45.636590)
    static var RADIUSFACTORY = 1000.0
    static var ACTIVATENOTIFICATIONOUT = false
    
    static var PROPORTIONALPORTARIA = 0.8
    static var PROPORTIONALPATIO = 1.2
    static var PROPORTIONALPATIOBALANCA = 0.7
}
