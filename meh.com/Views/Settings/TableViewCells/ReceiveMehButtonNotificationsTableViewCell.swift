//
//  ReceiveMehButtonNotificationsTableViewCell.swift
//  meh.com
//
//  Created by Kirin Patel on 2/7/21.
//  Copyright © 2021 Kirin Patel. All rights reserved.
//

import UIKit

class ReceiveMehButtonNotificationsTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "receiveNotifications"
    
    @IBOutlet var toggle: UISwitch?
    
    @IBAction func toggleValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            NotificationsManager.shared.enableReminderNotifications()
        } else {
            NotificationsManager.shared.disableReminderNotifications()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationsManager.shared.addListener(listener: self)
    }
    
    override func awakeFromNib() {
        toggle?.isOn = NotificationsManager.shared.getReminderNotifiationState()
    }
    
    deinit {
        NotificationsManager.shared.removeListener(listener: self)
    }
}

extension ReceiveMehButtonNotificationsTableViewCell: NotificationsManagerListener {
    var id: String {
        return "ReceiveMehButtonNotificationsTableViewCell"
    }
    
    func notificationStateChanged(enabled: Bool) {
        
    }
    
    func notificationStateChangeFailed(granted: Bool, error: Error?) {
        
    }
    
    func reminderNotificationStateChanged(enabled: Bool) {
        DispatchQueue.main.async(execute: {
            self.toggle?.isOn = enabled
        })
    }
    
    func reminderNotificationStateChangeFailed(error: Error?) {
        DispatchQueue.main.async(execute: {
            self.toggle?.isOn = false
        })
    }
    
    func reminderNotificiationTimeChanged(time: String) {
        
    }
}
