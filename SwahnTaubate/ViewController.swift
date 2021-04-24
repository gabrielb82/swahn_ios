//
//  ViewController.swift
//  SwahnTaubate
//
//  Created by Gabriel Barbosa on 21/11/18.
//

import UIKit
import Firebase
import FirebaseFirestore
import CoreLocation
import JMMaskTextField_Swift
import MapKit
import UserNotifications

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placaTextField: JMMaskTextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    
    var locationManager :CLLocationManager! = nil
    var truck:Truck!
    var journeyName:String!
    var timer:Timer!
    var startDate:Date!
    var canGetLocal = false
    var warehouseCalculator = WarehouseCalculator()
    var appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    
    var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placaTextField.delegate = self
        locationManager = CLLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.activityType = .automotiveNavigation
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        }
        
        
        if let _ = appVersion {
            versionLabel.text = "Version: \(appVersion!)"
        }
        placaTextField.isEnabled = false
        FirebaseManager.sharedInstance.updateConfig { (_) in
            self.placaTextField.isEnabled = true
        }
        FirebaseManager.sharedInstance.activateForceUpdate()
        batteryLevelDidChange(Notification(name: .NSUndoManagerWillUndoChange))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.createAlert(title: "Atenção", string: "Este aplicativo está em desenvolvimento, e tem o propósito de ser um Proof of Concept para realizar o rastreamento de caminhões na planta VW Taubaté. Qualquer dúvida entrar em contato com leonardo.geus@t-systems.com.br")
    }
    
    @objc func batteryLevelDidChange(_ notification: Notification) {
        print(batteryLevel)
        let name = UIDevice.current.name
        if let  _ = appVersion {
        } else {
            self.appVersion = "-"
        }
    
        FirebaseManager.sharedInstance.didGetBatteryStatus(battery: batteryLevel, version: appVersion!, deviceName: name )
    }
    
    
    
    @IBAction func startButtonTap(_ sender: Any) {
        if startButton.titleLabel?.text == "Iniciar" {
            locationManager.startUpdatingLocation()
            let license  = placaTextField.text!.uppercased()
            
            if license.count > 4 {
                truck = Truck(license: license, journey: [])
                startButton.setTitle("Terminar Jornada", for: .normal)
                placaTextField.resignFirstResponder()
                FirebaseManager.sharedInstance.didTruckInit(truck: truck) { (numberOfJourneys) in
                    self.initTeste(journeyCount: numberOfJourneys)
                }
            } else {
                createAlert(title: "Atenção", string: "O CVA foi digitado incorretamente, por favor insira mais caracteres.")
            }
            
        } else {
            let alert = UIAlertController(title: "Cancelar", message: "Você deseja encerrar a viagem do caminhão \(truck.license)", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "SENHA"
                textField.keyboardType = .decimalPad
                
            })
            alert.addAction(UIAlertAction(title: "Encerrar Viagem", style: .default, handler: { action in
                let firstTextField = alert.textFields![0] as UITextField
                if firstTextField.text == CONSTS.SENHA {
                    self.locationManager.stopUpdatingLocation()
                    let end = Date()
                    if let _ = self.warehouseCalculator.journeyName {
                        FirebaseManager.sharedInstance.didCloseJourney(truck: self.truck, journeyName: self.journeyName, startDate: self.startDate,end: end)
                        if let _ = FirebaseManager.sharedInstance.auxStartForWay {
                            self.warehouseCalculator.closeWay(end: end)
                        }
                        self.startButton.setTitle("Iniciar", for: .normal)
                        self.placaTextField.text = ""
                        self.warehouseCalculator.actualWarehouse = nil
                        self.warehouseCalculator.auxWarehouse = []
                        self.warehouseCalculator.journeyName = ""
                        self.warehouseCalculator.didEnterWarehouseTime = nil
                        self.warehouseCalculator.truck = nil
                        self.truck = nil
                        self.journeyName = nil
                        self.timer.invalidate()
                        self.timer = nil
                        self.startDate = nil
                    } else {
                        fatalError("Fail to GET journeyName")
                    }
                    
                } else {
                    self.createAlert(title:"Atenção",string: "SENHA INCORRETA PARA DESATIVAR")
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func createAlert(title:String,string:String) {
        let alert = UIAlertController(title: title, message: string, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func initTeste(journeyCount:Int) {
        startDate = Date()
        startButton.setTitle("Terminar Jornada", for: .normal)
        journeyName = FirebaseManager.sharedInstance.didStartJourney(truck: truck, journeyCount: journeyCount, startDate: startDate)
        if let _ = journeyName {
        } else {
            fatalError()
        }
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(CONSTS.TIMETOGETLOCAL), repeats: true, block: { (timer) in
            self.canGetLocal = true
        })
    }

    
}

extension ViewController:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        if canGetLocal {
            
            if let _ = journeyName {
                if journeyName != "" {
                    warehouseCalculator.workWith(actualLocation: location, truck: truck, journeyName: journeyName)
                } else {
                    fatalError()
                }
            }
        }
        self.canGetLocal = false
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
    }
}

extension ViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: string.uppercased())
        
        if (textField.text?.count)! > 0 && (textField.text?.count)! < 3 {
            textField.keyboardType = .alphabet
        } else {
            textField.keyboardType = .numbersAndPunctuation
        }
        textField.reloadInputViews()
        
        return false
    }
}
