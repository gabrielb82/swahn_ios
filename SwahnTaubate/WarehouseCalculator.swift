//
//  Utils.swift
//  SwahnTaubate
//
//  Created by Gabriel Barbosa on 21/11/18.
//

import UIKit
import CoreLocation
import Firebase
import UserNotifications

class WarehouseCalculator {
    var points = [Dictionary<Warehouse, Int>]()
    var didEnterWarehouseTime:Date!
    var countAux = 0
    var actualWarehouse:Warehouse?
    var auxWarehouse = [WarehousePlusLocation?]()
    var truck:Truck!
    var journeyName:String!
    
    init() {
    }
    
    var warehouses:[(Warehouse,CLLocation)] {
        get {
            return [(.Patio,WarehouseCoordinate.Patio),
                    (.Portaria,WarehouseCoordinate.Portaria),
                    (.Recebimento1,WarehouseCoordinate.Recebimento1),
                    (.Recebimento2,WarehouseCoordinate.Recebimento2),
                    (.Recebimento3,WarehouseCoordinate.Recebimento3),
                    (.Inflamavel,WarehouseCoordinate.Inflamavel),
                    (.Vasilhame,WarehouseCoordinate.Vasilhame),
                    (.PatioBalanca,WarehouseCoordinate.PatioBalanca)]
        }
    }
    
    internal func testIfCoordinateIsInRegion(actualLocation:CLLocation) -> Warehouse {
        for warehouse in warehouses {
            let distance = warehouse.1.distance(from: actualLocation)
            if distance < CONSTS.DISTANCETOCONSIDER {
                if warehouse.0 == .Portaria {
                    if distance < CONSTS.DISTANCETOCONSIDER*CONSTS.PROPORTIONALPORTARIA {
                        return .Portaria
                    }
                }
                else if warehouse.0 == .Patio {
                    if distance < CONSTS.DISTANCETOCONSIDER*CONSTS.PROPORTIONALPATIO {
                        return .Patio
                    }
                } else if warehouse.0 == .PatioBalanca {
                    if distance < CONSTS.DISTANCETOCONSIDER*CONSTS.PROPORTIONALPATIOBALANCA {
                        return .PatioBalanca
                    }
                } else {
                    return warehouse.0
                }
            }
        }
        return .NoWhere
    }
    
    struct WarehousePlusLocation {
        var warehouse:Warehouse?
        var location:CLLocation!
    }
    
    func workWith(actualLocation:CLLocation,truck:Truck,journeyName:String) {
        self.truck = truck
        self.journeyName = journeyName
        let warehouse = testIfCoordinateIsInRegion(actualLocation: actualLocation)
        syncNewCoordinate(location: actualLocation,truck: truck,journeyName: journeyName, warehouse: warehouse)
        auxWarehouse.append(WarehousePlusLocation(warehouse: warehouse, location: actualLocation))
        if testTime() {
            printArray()
            let foundedWarehouse = discoverWarehouse()
            if let _ = actualWarehouse {
            } else {
                didEnterWarehouseTime = findFirstTimeIn(warehouse: foundedWarehouse)
                createEnterInWarehouseStatus(warehouse: foundedWarehouse, date: didEnterWarehouseTime)
                actualWarehouse = foundedWarehouse
            }
            if actualWarehouse != foundedWarehouse {
                didEnterWarehouseTime = findFirstTimeIn(warehouse: foundedWarehouse)
                createLeavedWarehouse(warehouse: actualWarehouse, date: didEnterWarehouseTime)
                createEnterInWarehouseStatus(warehouse: foundedWarehouse, date: didEnterWarehouseTime)
                actualWarehouse = foundedWarehouse
                
            }
            auxWarehouse = []
        }
    }
    
    func syncNewCoordinate(location:CLLocation,truck:Truck,journeyName:String,warehouse:Warehouse) {
        if truck.license != "" {
            FirebaseManager.sharedInstance.didReceiveNewCoordinate(truck: truck, location: location, journeyName: journeyName, warehouse: warehouse)
            if testIfLocationIsOutOfArea(location) {
                if !sendedNotification {
                    if CONSTS.ACTIVATENOTIFICATIONOUT {
                        Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { (timer) in
                            self.sendedNotification = false
                        }
                        FirebaseManager.sharedInstance.receivedOutNotification(truck: truck, time: location.timestamp, location: GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                        sendedNotification = true
                        sendLocalNotification(title: "Atenção", message: "Este celular foi retirado de dentro da planta VW Taubaté, entre dentro da área imediatamente.")
                    }
                }
            }
        }
    }
    
    var sendedNotification = false
    
    func testIfLocationIsOutOfArea(_ location:CLLocation) -> Bool {
        let distance = CLLocation(latitude: CONSTS.CENTEROFFACTORY.latitude, longitude: CONSTS.CENTEROFFACTORY.longitude).distance(from: location)
        if distance < CONSTS.RADIUSFACTORY {
            return false
        } else {
            return true
        }
    }
    
    func closeWay(end:Date) {
        FirebaseManager.sharedInstance.didCloseWay(truck: truck, end: end, journeyName: journeyName)
    }
    
    func sendLocalNotification(title:String, message:String) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: message, arguments: nil)
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "notify-swahn"
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest.init(identifier: "notify-swahn", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
    
    func printArray() {
        for ware in auxWarehouse {
            if ware!.warehouse! == .Portaria {
                print("ACHOU PORTÃO")
            }
            print("ware: \(ware!.warehouse!) at \(ware!.location!.timestamp)")
        }
    }
    
    func createEnterInWarehouseStatus(warehouse:Warehouse,date:Date) {
        print("Entered in \(warehouse) at \(date)")
        FirebaseManager.sharedInstance.didEnterOnWarehouse(warehouse: warehouse, time: date, truck: truck, journeyName: journeyName)
    }
    
    func createLeavedWarehouse(warehouse:Warehouse?,date:Date) {
        print("Leaved of \(warehouse ?? .NoWhere) at \(date)")
        if let warehouse = warehouse {
            FirebaseManager.sharedInstance.didLeaveWarehouse(warehouse: warehouse, time: date, truck: truck, journeyName: journeyName)
        }
    }
    
    func testTime() -> Bool {
        let first = auxWarehouse.first
        let last = auxWarehouse.last
        let differenceTime = last?!.location.timestamp.timeIntervalSince(((first?!.location.timestamp))!)
        if let differenceTime = differenceTime {
            if Int(differenceTime) > CONSTS.NUMBEROFSECONDSTOWAITTOCONSIDER {
                return true
            } else {
                return false
            }
        } else {
            fatalError("DifferenceTime can't be nul")
        }
    }
    
    func discoverWarehouse() -> Warehouse {
        var points = Dictionary<Warehouse,Int>()
        for warehouse in warehouses {
            points[warehouse.0] = 0
        }
        points[.NoWhere] = 0
        for poi in auxWarehouse {
            if let warehouse = poi?.warehouse {
                points[warehouse] = points[warehouse]! + 1
            } else {
                points[.NoWhere] = points[.NoWhere]! + 1
            }
        }
        var percents = Dictionary<Warehouse,Double>()
        let possiblePoints = auxWarehouse.count
        for value in points {
            let warehouse = value.key
            let point = value.value
            percents[warehouse] = Double(point)/Double(possiblePoints)
        }
        for value in percents {
            if value.value > Double(CONSTS.THRESHOLDTOCONSIDERWAREHOUSE)/100.0 {
                print("Truck is in \(value.key) with \(value.value) percent")
                if value.key == .NoWhere {
                    return .NoWhere
                } else {
                    return value.key
                }
            }
        }
        return .NoWhere
    }
    
    func findFirstTimeIn(warehouse:Warehouse) -> Date {
        for ware in auxWarehouse {
            if ware?.warehouse == warehouse {
                return (ware?.location.timestamp)!
            }
        }
        fatalError("Didn't find any first time in this warehouse")
    }
}
