//
//  FirebaseManager.swift
//  SwahnTaubate
//
//  Created by Gabriel Barbosa on 21/11/18.
//

import UIKit
import FirebaseFirestore
import CoreLocation

class FirebaseManager {
    
    var db:Firestore!
    
    static let sharedInstance = FirebaseManager()
    var journeyDb:CollectionReference!
    var auxIdForWay = ""
    var auxStartForWay:Date!
    
    private init() {
        db = Firestore.firestore()
    }
    
    func activateForceUpdate() {
        db.collection("config").document("key").addSnapshotListener { (document, error) in
            self.updateConfig(completion: { (result) in
                print("forced updated of config")
            })
        }
    }
    
    func updateConfig(completion: @escaping (_ result:Any? ) -> Void) {
        
        db.collection("config").document("warehouses").getDocument { (snapshot, error) in
            if let Inflamavel = snapshot?.data()?["Inflamavel"] {
                if let Inflamavel = Inflamavel as? GeoPoint {
                    WarehouseCoordinate.Inflamavel = CLLocation(latitude: Inflamavel.latitude, longitude: Inflamavel.longitude)
                }
            }
            if let Patio = snapshot?.data()?["Patio"] {
                if let Patio = Patio as? GeoPoint {
                    WarehouseCoordinate.Patio = CLLocation(latitude: Patio.latitude, longitude: Patio.longitude)
                }
            }
            if let Portaria = snapshot?.data()?["Portaria"] {
                if let Portaria = Portaria as? GeoPoint {
                    WarehouseCoordinate.Portaria = CLLocation(latitude: Portaria.latitude, longitude: Portaria.longitude)
                }
            }
            if let Recebimento1 = snapshot?.data()?["Recebimento1"] {
                if let Recebimento1 = Recebimento1 as? GeoPoint {
                    WarehouseCoordinate.Recebimento1 = CLLocation(latitude: Recebimento1.latitude, longitude: Recebimento1.longitude)
                }
            }
            if let Recebimento2 = snapshot?.data()?["Recebimento2"] {
                if let Recebimento2 = Recebimento2 as? GeoPoint {
                    WarehouseCoordinate.Recebimento2 = CLLocation(latitude: Recebimento2.latitude, longitude: Recebimento2.longitude)
                }
            }
            if let Recebimento3 = snapshot?.data()?["Recebimento3"] {
                if let Recebimento3 = Recebimento3 as? GeoPoint {
                    WarehouseCoordinate.Recebimento3 = CLLocation(latitude: Recebimento3.latitude, longitude: Recebimento3.longitude)
                }
            }
            if let Vasilhame = snapshot?.data()?["Vasilhame"] {
                if let Vasilhame = Vasilhame as? GeoPoint {
                    WarehouseCoordinate.Vasilhame = CLLocation(latitude: Vasilhame.latitude, longitude: Vasilhame.longitude)
                }
            }
            
            if let PatioBalanca = snapshot?.data()?["PatioBalanca"] {
                if let PatioBalanca = PatioBalanca as? GeoPoint {
                    WarehouseCoordinate.PatioBalanca = CLLocation(latitude: PatioBalanca.latitude, longitude: PatioBalanca.longitude)
                }
            }
            
            self.db.collection("config").document("default").getDocument { (snapshot, error) in
                if let DISTANCETOCONSIDER = snapshot?.data()?["DISTANCETOCONSIDER"] {
                    if let DISTANCETOCONSIDER = DISTANCETOCONSIDER as? Int {
                        CONSTS.DISTANCETOCONSIDER = Double(DISTANCETOCONSIDER)
                    }
                }
                if let NUMBEROFLOCATION = snapshot?.data()?["NUMBEROFLOCATION"] {
                    if let NUMBEROFLOCATION = NUMBEROFLOCATION as? Int {
                        CONSTS.NUMBEROFLOCATION = NUMBEROFLOCATION
                    }
                }
                if let NUMBEROFSECONDSTOWAITTOCONSIDER = snapshot?.data()?["NUMBEROFSECONDSTOWAITTOCONSIDER"] {
                    if let NUMBEROFSECONDSTOWAITTOCONSIDER = NUMBEROFSECONDSTOWAITTOCONSIDER as? Int {
                        CONSTS.NUMBEROFSECONDSTOWAITTOCONSIDER = NUMBEROFSECONDSTOWAITTOCONSIDER
                    }
                }
                if let SENHA = snapshot?.data()?["SENHA"] {
                    if let SENHA = SENHA as? String {
                        CONSTS.SENHA = SENHA
                    }
                }
                if let THRESHOLDTOCONSIDERWAREHOUSE = snapshot?.data()?["THRESHOLDTOCONSIDERWAREHOUSE"] {
                    if let THRESHOLDTOCONSIDERWAREHOUSE = THRESHOLDTOCONSIDERWAREHOUSE as? Int {
                        CONSTS.THRESHOLDTOCONSIDERWAREHOUSE = THRESHOLDTOCONSIDERWAREHOUSE
                    }
                }
                if let TIMETOENTERINWAREHOUSE = snapshot?.data()?["TIMETOENTERINWAREHOUSE"] {
                    if let TIMETOENTERINWAREHOUSE = TIMETOENTERINWAREHOUSE as? Int {
                        CONSTS.TIMETOENTERINWAREHOUSE = TIMETOENTERINWAREHOUSE
                    }
                }
                if let TIMETOGETLOCAL = snapshot?.data()?["TIMETOGETLOCAL"] {
                    if let TIMETOGETLOCAL = TIMETOGETLOCAL as? Int {
                        CONSTS.TIMETOGETLOCAL = TIMETOGETLOCAL
                    }
                }
                if let TIMETOENTERINWAREHOUSE = snapshot?.data()?["TIMETOENTERINWAREHOUSE"] {
                    if let TIMETOENTERINWAREHOUSE = TIMETOENTERINWAREHOUSE as? Int {
                        CONSTS.TIMETOENTERINWAREHOUSE = TIMETOENTERINWAREHOUSE
                    }
                }
                if let CENTEROFFACTORY = snapshot?.data()?["CENTEROFFACTORY"] {
                    if let CENTEROFFACTORY = CENTEROFFACTORY as? GeoPoint {
                        CONSTS.CENTEROFFACTORY = CENTEROFFACTORY
                    }
                }
                if let RADIUSFACTORY = snapshot?.data()?["RADIUSFACTORY"] {
                    if let RADIUSFACTORY = RADIUSFACTORY as? Double {
                        CONSTS.RADIUSFACTORY = RADIUSFACTORY
                    }
                }
                if let ACTIVATENOTIFICATIONOUT = snapshot?.data()?["ACTIVATENOTIFICATIONOUT"] {
                    if let ACTIVATENOTIFICATIONOUT = ACTIVATENOTIFICATIONOUT as? Bool {
                        CONSTS.ACTIVATENOTIFICATIONOUT = ACTIVATENOTIFICATIONOUT
                    }
                }
                if let PROPORTIONALPORTARIA = snapshot?.data()?["PROPORTIONALPORTARIA"] {
                    if let PROPORTIONALPORTARIA = PROPORTIONALPORTARIA as? Double {
                        CONSTS.PROPORTIONALPORTARIA = PROPORTIONALPORTARIA
                    }
                }
                if let PROPORTIONALPATIO = snapshot?.data()?["PROPORTIONALPATIO"] {
                    if let PROPORTIONALPATIO = PROPORTIONALPATIO as? Double {
                        CONSTS.PROPORTIONALPATIO = PROPORTIONALPATIO
                    }
                }
                if let PROPORTIONALPATIOBALANCA = snapshot?.data()?["PROPORTIONALPATIOBALANCA"] {
                    if let PROPORTIONALPATIOBALANCA = PROPORTIONALPATIOBALANCA as? Double {
                        CONSTS.PROPORTIONALPATIOBALANCA = PROPORTIONALPATIOBALANCA
                    }
                }
                completion(nil)
            }
        }
        
        
        
    }
    
    func didEnterOnWarehouse(warehouse:Warehouse,time:Date,truck:Truck,journeyName:String) {
        let data = ["warehouse":"\(warehouse)","start":time] as [String : Any]
        auxStartForWay = time
        auxIdForWay = self.db.collection("truck1")
                    .document(truck.license)
                    .collection("journeys")
                    .document(journeyName)
                    .collection("way")
                    .addDocument(data: data).documentID
    }
    
    func didLeaveWarehouse(warehouse:Warehouse,time:Date,truck:Truck,journeyName:String) {
        
        let duration = time.timeIntervalSince(auxStartForWay)
        let data = ["end":time,"duration":duration] as [String : Any]
        
        self.db.collection("truck1")
            .document(truck.license)
            .collection("journeys")
            .document(journeyName)
            .collection("way")
            .document(auxIdForWay)
            .setData(data, merge: true)
        
        
        let data2 = ["truck":truck.license,"journeyName":journeyName,"duration":duration,"start":auxStartForWay] as [String : Any]
        
        self.db.collection("warehouse1")
            .document("\(warehouse)")
            .collection("stays")
            .addDocument(data: data2)
        
        
        
        NetLayer.sharedInstance.get(url: "https://us-central1-swahn-612fb.cloudfunctions.net/didLeaveOfWarehouse?warehouse=\(warehouse)&duration=\(Double(duration))") { (result) in
        }
        
        auxStartForWay = nil
        auxIdForWay = ""
    }
    
    func didCloseWay(truck:Truck,end:Date,journeyName:String) {
        
        let duration = end.timeIntervalSince(auxStartForWay)
        let data = ["end":end,"duration":duration] as [String : Any]
        
     
        self.db.collection("truck1")
            .document(truck.license)
            .collection("journeys")
            .document(journeyName)
            .collection("way")
            .document(auxIdForWay)
            .setData(data, merge: true)
    }
    
    func didReceiveNewCoordinate(truck:Truck,location:CLLocation,journeyName:String,warehouse:Warehouse) {
        let geoPoint = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let data = ["location":geoPoint,"warehouse":"\(warehouse)","lastUpdate":location.timestamp] as [String : Any]
        
        let name = UIDevice.current.name
        self.db.collection("devices").document(name).setData(["location":geoPoint,"lastUpdate":location.timestamp], merge: true)
        self.db.collection("truck1").document(truck.license).setData(data, merge: true)
        journeyDb.document(journeyName).collection("positions").addDocument(data: ["date":location.timestamp,"coordinate":geoPoint,"altitude":location.altitude,"horizaontalAccuracy":location.horizontalAccuracy,"speed":location.speed])
    }
    
    func didGetBatteryStatus(battery:Float,version:String,deviceName:String) {
        let data = ["battery":battery,"version":version,"deviceName":deviceName,"lastUpdateBattery":Date()] as [String : Any]
        db.collection("devices").document(deviceName).setData(data, merge: true)
    }
    
    func receivedOutNotification(truck:Truck,time:Date,location:GeoPoint) {
        db.collection("outNotification").addDocument(data: ["truck":truck.license,"start":time,"location":location])
    }
    
    func didStartJourney(truck:Truck,journeyCount:Int,startDate:Date) -> String {
        let name = UIDevice.current.name
        db.collection("truck1").document(truck.license).setData(["numberOfJourneys":journeyCount,"device":name], merge: true)
        journeyDb = db.collection("truck1").document(truck.license).collection("journeys")
        let journeyName = journeyDb.addDocument(data: ["start":startDate]).documentID
        let data = ["journey":journeyName,"start":startDate] as [String : Any]
        self.db.collection("truck1").document(truck.license).setData(data, merge: true)
        return journeyName
    }
    
    func didCloseJourney(truck:Truck,journeyName:String,startDate:Date,end:Date) {
        
        let diffence = end.timeIntervalSince(startDate)
       
        NetLayer.sharedInstance.get(url: "https://us-central1-swahn-612fb.cloudfunctions.net/didFinishedJourney?journeyName=\(journeyName)&duration=\(Double(diffence))") { (result) in
            
        }
    self.db.collection("truck1").document(truck.license).collection("journeys").document(journeyName).setData(["end":end,"duration":Double(diffence)], merge: true)
        
        let data = ["end":end] as [String : Any]
        self.db.collection("truck1").document(truck.license).setData(data, merge: true)
        self.journeyDb = nil
    }
    
    func didTruckInit(truck:Truck,completion: @escaping (_ numberOfJourneys: Int) -> Void) {
        db.collection("truck1").document(truck.license).setData(["license":truck.license],merge: true)
        
        db.collection("truck1").document(truck.license).getDocument { (snapshot, error) in
            var number = 0
            if let numberOfJourneys = snapshot?.data()?["numberOfJourneys"] {
                if let nu = numberOfJourneys as? Int {
                    number = nu
                }
            }
            number = number + 1
            completion(number)
            
        }
    }
    
}
