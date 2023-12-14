//
//  AppDelegate.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 13.08.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CoreDataManager.shared.load()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}





//    func configureDataSource() {
//        let cellRegistration = UICollectionView.CellRegistration
//        <CustomCollectionViewCell, String> { (cell, indexPath, text) in
//            // Populate the cell with our item description.
//            cell..text = text
//
//            if self.expandedcell.contains(indexPath.item) {
//                cell.textLbl.numberOfLines = 0
//                cell.moreBtn.setTitle("See Less", for: .normal)
//            } else {
//                cell.textLbl.numberOfLines = 3
//                cell.moreBtn.setTitle("See More", for: .normal)
//            }
//
//            cell.butttonClicked = {
//                if self.expandedcell.contains(indexPath.item) {
//                    self.expandedcell.remove(indexPath.item)
//                } else {
//                    self.expandedcell.insert(indexPath.item)
//                }
//
//                self.currentSnapshot.reloadItems([text])
//                self.dataSource.apply(self.currentSnapshot, animatingDifferences: false)
//            }
//
//        }
