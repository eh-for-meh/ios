//
//  AppDelegate.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = LoadingViewController()
        self.window?.makeKeyAndVisible()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
        case "Delete":
            print("Delete")
        default:
            print("Unknown action")
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.content.title == "Today's deal is almost over!" {
            DealLoader.sharedInstance.loadCurrentDeal(completion: { deal in
                let dealId: String = UserDefaults.standard.string(forKey: "meh") ?? ""
                
                // Only show notification to press meh for day if it has not
                // already been pressed by a user.
                if deal.id != dealId {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    completionHandler([.alert, .badge, .sound])
                }
            })
        } else {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            completionHandler([.alert, .badge, .sound])
        }
    }
}

