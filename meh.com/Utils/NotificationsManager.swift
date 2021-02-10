//
//  NotificationsManager.swift
//  meh.com
//
//  Created by Kirin Patel on 2/6/21.
//  Copyright © 2021 Kirin Patel. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseMessaging
import UserNotifications

protocol NotificationsManagerListener {
    var id: String { get }
    func notificationStateChanged(enabled: Bool)
    func notificationStateChangeFailed(granted: Bool, error: Error?)
    func reminderNotificationStateChanged(enabled: Bool)
    func reminderNotificationStateChangeFailed(error: Error?)
    func reminderNotificiationTimeChanged(time: String)
}

class NotificationsManager {
    
    static let shared = NotificationsManager()
    
    private var listeners: [NotificationsManagerListener] = []
    
    func addListener(listener: NotificationsManagerListener) {
        listeners.append(listener)
    }
    
    func removeListener(listener: NotificationsManagerListener) {
        listeners = listeners.filter { $0.id != listener.id }
    }
    
    // MARK: Getters
    
    func getNotifiationState() -> Bool {
        UserDefaults.standard.bool(forKey: "receiveNotifications")
    }
    
    func getReminderNotifiationState() -> Bool {
        UserDefaults.standard.bool(forKey: "remindForMeh")
    }
    
    func getReminderNotifiationTime() -> String {
        UserDefaults.standard.string(forKey: "reminderTime") ?? "6:00 PM"
    }
    
    private func getFMCToken() -> String {
        return Messaging.messaging().fcmToken!
    }
    
    // MARK: Notifications
    
    func enableNotifications() {
        let current = UNUserNotificationCenter.current()
        current.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            if granted == true && error == nil {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                    UserDefaults.standard.set(true, forKey: "receiveNotifications")
                    Database.database().reference().child("notifications/\(self.getFMCToken())").setValue(true)
                    self.listeners.forEach({ $0.notificationStateChanged(enabled: true) })
                })
            } else {
                self.listeners.forEach({ $0.notificationStateChangeFailed(granted: granted, error: error )})
            }
        }
    }
    
    func disableNotifications() {
        UserDefaults.standard.set(false, forKey: "receiveNotifications")
        Database.database().reference().child("notifications/\(self.getFMCToken())").removeValue()
        self.listeners.forEach({ $0.notificationStateChanged(enabled: false) })
        disableReminderNotifications()
    }
    
    // MARK: Reminder Notifications
    
    func enableReminderNotifications() {
        let current = UNUserNotificationCenter.current()
        current.removeAllPendingNotificationRequests()
        let content = UNMutableNotificationContent()
        content.title = "Today's deal is almost over!"
        content.body = "Don't forget to press the meh button today"
        content.sound = UNNotificationSound.default
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.defaultDate = Date(timeIntervalSinceReferenceDate: 0)
        guard let testDate = formatter.date(from: getReminderNotifiationTime()) else { return }
        let triggerDate = Calendar.current.dateComponents([.hour,.minute,.second], from: testDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        let request = UNNotificationRequest(identifier: "com.kirinpatel.meh", content: content, trigger: trigger)
        current.add(request, withCompletionHandler: { (error) in
            if let error = error {
                UserDefaults.standard.set(false, forKey: "remindForMeh")
                self.updateReminderNotificationsTime(time: "6:00 PM")
                self.listeners.forEach({ $0.reminderNotificationStateChangeFailed(error: error) })
            } else {
                UserDefaults.standard.set(true, forKey: "remindForMeh")
                self.updateReminderNotificationsTime(time: "6:00 PM")
                self.listeners.forEach({ $0.reminderNotificationStateChanged(enabled: true) })
            }
        })
    }
    
    func disableReminderNotifications() {
        let current = UNUserNotificationCenter.current()
        current.removeAllPendingNotificationRequests()
        UserDefaults.standard.set(false, forKey: "remindForMeh")
        self.listeners.forEach({ $0.reminderNotificationStateChanged(enabled: false) })
        updateReminderNotificationsTime(time: "6:00 PM")
    }
    
    func updateReminderNotificationsTime(time: String) {
        UserDefaults.standard.set(time, forKey: "reminderTime")
        self.listeners.forEach({ $0.reminderNotificiationTimeChanged(time: time) })
    }
}
