//
//  NetLayer.swift
//  SwahnTaubate
//
//  Created by Gabriel Barbosa on 21/11/18.
//

import UIKit


class NetLayer {
    
    static let sharedInstance = NetLayer()
    
    private init() {
    }
    
    func get(url:String, completion: @escaping (_ result: String) -> Void) {
        
        let url = URL(string: url)!
        let session = URLSession.shared
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            completion(String(data: data, encoding: String.Encoding.utf8)!)
        })
        
        task.resume()
    }
}
