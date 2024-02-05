//
//  AppDelegate.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 13.08.2023.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let shared = UIApplication.shared.delegate as! AppDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        presistenceContainer = NSPersistentContainer(name: "MoviesApp")
        presistenceContainer.loadPersistentStores { description, error in
            if let error {
                print(error)
            }
        }
        return true
    }
        
        // MARK: UISceneSession Lifecycle
        
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
        
    var presistenceContainer: NSPersistentContainer!
}




