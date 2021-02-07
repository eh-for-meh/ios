//
//  ReceiveMehButtonNotificationTimeTableViewCell.swift
//  meh.com
//
//  Created by Kirin Patel on 2/7/21.
//  Copyright © 2021 Kirin Patel. All rights reserved.
//

import UIKit

class ReceiveMehButtonNotificationTimeTableViewCell: UITableViewCell {
    
    @IBOutlet var timePicker: UIDatePicker?

    @IBAction func timeValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let time = formatter.string(from: sender.date)
        NotificationsManager.shared.updateReminderNotificationsTime(time: time)
        NotificationsManager.shared.enableReminderNotifications()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationsManager.shared.addListener(listener: self)
    }
    
    override func awakeFromNib() {
        setTime(time: NotificationsManager.shared.getReminderNotifiationTime())
    }
    
    deinit {
        NotificationsManager.shared.removeListener(listener: self)
    }
    
    fileprivate func setTime(time: String) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.defaultDate = Date(timeIntervalSinceReferenceDate: 0)
        guard let date = formatter.date(from: time) else { return }
        timePicker?.date = date
    }
}

extension ReceiveMehButtonNotificationTimeTableViewCell: NotificationsManagerListener {
    var id: String {
        return "ReceiveMehButtonNotificationTimeTableViewCell:"
    }
    
    func notificationStateChanged(enabled: Bool) {
        
    }
    
    func notificationStateChangeFailed(granted: Bool, error: Error?) {
        
    }
    
    func reminderNotificationStateChanged(enabled: Bool) {
        
    }
    
    func reminderNotificationStateChangeFailed(error: Error?) {
        
    }
    
    func reminderNotificiationTimeChanged(time: String) {
        DispatchQueue.main.async(execute: {
            self.setTime(time: time)
        })
    }
}
