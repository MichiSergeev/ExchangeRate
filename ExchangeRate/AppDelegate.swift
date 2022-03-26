//
//  AppDelegate.swift
//  ExchangeRate
//
//  Created by Mikhail Sergeev on 26.03.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.rootViewController?.view.backgroundColor = .yellow
        window?.makeKeyAndVisible()
        
        return true
    }

}

