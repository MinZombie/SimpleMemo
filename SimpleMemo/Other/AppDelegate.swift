//
//  AppDelegate.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// realm 파일이 있는 기본 경로
        let defaultRealm = Realm.Configuration.defaultConfiguration.fileURL!
        
        /// group 경로
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.headingtodev.simplememo")
        
        /// group에 realm 파일 추가하면 완성되는 경로
        let realmURL = container?.appendingPathComponent("default.realm")
        
        /// config 초기화
        var config: Realm.Configuration!

        if FileManager.default.fileExists(atPath: defaultRealm.path) {
            do {

                _ = try FileManager.default.replaceItemAt(realmURL!, withItemAt: defaultRealm)

               config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
                
            } catch {
                
               print("Error info: \(error)")
            }
            
        } else {
            
             config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
        }
        
        // realm 기본 설정을 group에 있는 realm으로 설정
        Realm.Configuration.defaultConfiguration = config
        
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

