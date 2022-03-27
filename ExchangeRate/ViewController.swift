//
//  ViewController.swift
//  ExchangeRate
//
//  Created by Mikhail Sergeev on 26.03.2022.
//

import UIKit

class ViewController: UIViewController {
    
    let basePath = "https://openexchangerates.org/api/"
    let latest = "latest.json"
    let appID = "app_id"
    let id = "4502a35230eb4319987a07d2fba726b1"
    
    var json: Latest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLatestExchangeRate()
    }
    
    func getLatestExchangeRate() {
        guard let url = URL(string: basePath + latest + "?" + appID + "=" + id) else {
            print("url isn't correct")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                      print("statusCode != 200")
                      return
                  }
            
            guard let data = data else {
                print(error.debugDescription)
                return
            }
            
            do {
                self.json = try JSONDecoder().decode(Latest.self, from: data)
                print(self.json)
            } catch {
                print(error.localizedDescription)
            }
            
        }
        task.resume()
    }
    
}

