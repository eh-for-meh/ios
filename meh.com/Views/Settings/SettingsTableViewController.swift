//
//  SettingsViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/5/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseMessaging
import UserNotifications

class SettingsTableViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ReceiveNotificationsTableViewCell.self, forCellReuseIdentifier: ReceiveNotificationsTableViewCell.cellIdentifier)
        
        let backButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(handleBack))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let fmcToken = Messaging.messaging().fcmToken!
        Database.database().reference().child("notifications/\(fmcToken)").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                if let receiveNotifications = snapshot.value as? Bool {
                    if UserDefaults.standard.bool(forKey: "receiveNotifications") != receiveNotifications {
                        self.displayDatabaseErrorAlert(receiveNotifications: receiveNotifications)
                    }
                }
            }
        })
        
        NotificationsManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationsManager.shared.removeListener(listener: self)
    }
    
    @objc func handleBack() {
        dismiss(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSectionOne = (NotificationsManager.shared.getNotifiationState() ? 1 : 0) + (NotificationsManager.shared.getReminderNotifiationState() ? 1 : 0) + 1
        return [numberOfRowsInSectionOne, 2, 1][section]
    }
    
    fileprivate func displayDatabaseErrorAlert(receiveNotifications: Bool) {
        let alert = UIAlertController(title: "Notification Settings Error", message: "Your notifications are \(receiveNotifications ? "not" : "") enabled in the app but are in our database. Would you still like to recieve notifications?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
            Analytics.logEvent("setNotifications", parameters: [
                "recieveNotifications": true,
                "error": "Was not set in database."
                ])
            NotificationsManager.shared.enableNotifications()
        })
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: { _ in
            Analytics.logEvent("setNotifications", parameters: [
                "recieveNotifications": false,
                "error": "Was not set in database."
                ])
            NotificationsManager.shared.disableNotifications()
        })

        alert.addAction(yesAction)
        alert.addAction(noAction)

        present(alert, animated: true)
    }
    
    fileprivate func showSimpleAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default) { _ in
            if let completion = completion {
                completion()
            }
        })
        present(alert, animated: true)
    }
}

extension SettingsTableViewController: NotificationsManagerListener {
    var id: String {
        return "SettingsTableViewController"
    }
    
    func notificationStateChanged(enabled: Bool) {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func notificationStateChangeFailed(granted: Bool, error: Error?) {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.showSimpleAlert(title: "An unexpected error occurred!", message: "Notifications were unable to be enabled, please ensure that \"eh for meh\" can send notifications within your settings!")
        })
    }
    
    func reminderNotificationStateChanged(enabled: Bool) {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func reminderNotificationStateChangeFailed(error: Error?) {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.showSimpleAlert(title: "An unexpected error occurred!", message: "Notifications were unable to be enabled, please ensure that \"eh for meh\" can send notifications within your settings!")
        })
    }
    
    func reminderNotificiationTimeChanged(time: String) {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
}
