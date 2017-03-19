//
//  AppDelegate.swift
//  MemeMe
//
//  Created by Bryan Morfe on 1/6/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties

    var window: UIWindow?
    
    var memeEditorViewController: MemeEditorViewController?
    var activeViewController: UIViewController?
    
    var appTheme: AppTheme!
    var preferredFont: UIFont!
    
    var memes = [Meme]()
    
    // MARK: Constants Struct
    
    struct UserDefaultsKeys {
        static let hasLaunched = "HasLaunched"
        static let preferredFont = "PreferredFont"
        static let appTheme = "DarkTheme"
    }
    
    // MARK: Methods
    
    func loadAppTheme() {
        // Confession: I have taken a peak at the persistance and core data course
        
        // I will just make the settings persist through app lauches because it's more practical
        if let _ = UserDefaults.standard.value(forKey: AppDelegate.UserDefaultsKeys.hasLaunched) as? Bool {
            
            if let fontName = UserDefaults.standard.value(forKey: AppDelegate.UserDefaultsKeys.preferredFont) as? String {
                preferredFont = UIFont(name: fontName, size: 40)!
            }
            
            if let darkTheme = UserDefaults.standard.value(forKey: AppDelegate.UserDefaultsKeys.appTheme) as? Bool {
                // If it's true it's dark, otherwise it's light
                darkTheme ? (appTheme = .dark) : (appTheme = .light)
            }
        } else {
            appTheme = .light
            preferredFont = UIFont(name: "Impact", size: 40)!
            UserDefaults.standard.set(true, forKey: AppDelegate.UserDefaultsKeys.hasLaunched)
            UserDefaults.standard.set(false, forKey: AppDelegate.UserDefaultsKeys.appTheme)
            UserDefaults.standard.set("Impact", forKey: AppDelegate.UserDefaultsKeys.preferredFont)
        }
        
    }
    
    func saveSettings() {
        let darkTheme = appTheme == .dark ? true : false
        let fontName = preferredFont.fontName
        UserDefaults.standard.set(darkTheme, forKey: AppDelegate.UserDefaultsKeys.appTheme)
        UserDefaults.standard.set(fontName, forKey: AppDelegate.UserDefaultsKeys.preferredFont)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        loadAppTheme()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveSettings()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

