//
//  ReceiveNotificationsTableViewCell.swift
//  meh.com
//
//  Created by Kirin Patel on 2/6/21.
//  Copyright © 2021 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseMessaging
import UserNotifications

class ReceiveNotificationsTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "receiveNotifications"
    
    @IBOutlet var toggle: UISwitch?
    
    @IBAction func toggleValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            NotificationsManager.shared.enableNotifications()
        } else {
            NotificationsManager.shared.disableNotifications()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationsManager.shared.addListener(listener: self)
    }
    
    override func awakeFromNib() {
        toggle?.isOn = NotificationsManager.shared.getNotifiationState()
    }
    
    deinit {
        NotificationsManager.shared.removeListener(listener: self)
    }
}

extension ReceiveNotificationsTableViewCell: NotificationsManagerListener {
    var id: String {
        return "ReceiveNotificationsTableViewCell"
    }
    
    func notificationStateChanged(enabled: Bool) {
        DispatchQueue.main.async(execute: {
            self.toggle?.isOn = enabled
        })
    }
    
    func notificationStateChangeFailed(granted: Bool, error: Error?) {
        DispatchQueue.main.async(execute: {
            self.toggle?.isOn = false
        })
    }
    
    func reminderNotificationStateChanged(enabled: Bool) {
        
    }
    
    func reminderNotificationStateChangeFailed(error: Error?) {
        
    }
    
    func reminderNotificiationTimeChanged(time: String) {
        
    }
}
