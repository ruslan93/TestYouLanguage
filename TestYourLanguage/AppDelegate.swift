//
//  AppDelegate.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/20/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.prepareView()
        let config = Realm.Configuration(
            // Установим новую версию схемы. Это число должно быть больше предыдущей версии
            // (0, если вы никогда не устанавливали номер версии).
            schemaVersion: 4,
            // Определим блок, который будет вызван автоматически, при открытии Realm,
            // с версией схемы меньше чем определна выше
            migrationBlock: { migration, oldSchemaVersion in
                // Мы еще не проводили миграций, поэтому oldSchemaVersion == 0
                migration.enumerate(Language.className()) { oldObject, newObject in
                    // Добавим поле 'fullName' только к файлам Realm с версией схемы 0 или 1
                    if oldSchemaVersion < 4 {
                        newObject!["themes"] = List<Theme>()
                    }
                }
        })
        // Установить конфигурацию для Realm по умолчанию
        Realm.Configuration.defaultConfiguration = config
//        self.clearLoginData()
        return true
    }
    func clearLoginData(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("login")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    func prepareView() {
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

