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
import GoogleMobileAds
import QuickTableViewController
import UserNotifications

class SettingsViewController: QuickTableViewController, UNUserNotificationCenterDelegate {
    
    var notificationSwitch: SwitchRow<SwitchCell>!
    var mehReminderSwitch: SwitchRow<SwitchCell>!
    var radios: RadioSection!
    var interstitial: GADInterstitial!
    
    let effectView: UIVisualEffectView = {
        let vev = UIVisualEffectView()
        vev.translatesAutoresizingMaskIntoConstraints = false
        vev.isUserInteractionEnabled = true
        vev.effect = UIBlurEffect(style: .light)
        return vev
    }()
    
    let timePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .time
        return datePicker
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        let backButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(handleBack))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
        
        interstitial = loadInterstitial()
        
        if let dealHistoryCount: Int = UserDefaults.standard.object(forKey: "dealHistoryCount") as? Int {
            radios = RadioSection(title: "",
                                  options: [
                                    OptionRow(title: "5 Deals", isSelected: dealHistoryCount == 5, action: didToggleOption()),
                                    OptionRow(title: "10 Deals", isSelected: dealHistoryCount == 10, action: didToggleOption()),
                                    OptionRow(title: "20 Deals", isSelected: dealHistoryCount == 20, action: didToggleOption()),
                                    OptionRow(title: "50 Deals", isSelected: dealHistoryCount == 50, action: didToggleOption())
                ],
                                  footer: "Number of deals to display in history screen. Please note that the more deals you load, the more data/bandwidh will be used.")
        } else {
            radios = RadioSection(title: "",
                                  options: [
                                    OptionRow(title: "5 Deals", isSelected: false, action: didToggleOption()),
                                    OptionRow(title: "10 Deals", isSelected: false, action: didToggleOption()),
                                    OptionRow(title: "20 Deals", isSelected: UIDevice.current.userInterfaceIdiom != .pad, action: didToggleOption()),
                                    OptionRow(title: "50 Deals", isSelected: UIDevice.current.userInterfaceIdiom == .pad, action: didToggleOption())
                ],
                                  footer: "Number of deals to display in history screen. Please note that the more deals you load, the more data/bandwidh will be used.")
        }
        
        radios.alwaysSelectsOneOption = true
        
        timePicker.addTarget(self, action: #selector(startTimeDiveChanged), for: .valueChanged)
        closeButton.addTarget(self, action: #selector(closeTimePicker), for: .touchUpInside)
        
        setSectionOneRows()
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
    }
    
    @objc func handleBack() {
        dismiss(animated: true)
    }
    
    fileprivate func didToggleSelection() -> (Row) -> Void {
        return { [self] in
            if let option = $0 as? SwitchRowCompatible {
                switch option.title {
                case "Receive Notifications":
                    self.setNotificationsEnabled(enabled: option.switchValue)
                    break;
                case "Get Reminded to Press Meh":
                    self.setMehRemindersEnabled(enabled: option.switchValue)
                    break;
                case "Load images":
                    UserDefaults.standard.set(option.switchValue, forKey: "loadHistoryImages")
                    break;
                default:
                    break;
                }
            }
        }
    }
    
    private func didToggleOption() -> (Row) -> Void {
        return { row in
            switch row.title.split(separator: " ")[0] {
            case "5":
                UserDefaults.standard.set(5, forKey: "dealHistoryCount")
                break;
            case "10":
                UserDefaults.standard.set(10, forKey: "dealHistoryCount")
                break;
            case "50":
                UserDefaults.standard.set(50, forKey: "dealHistoryCount")
                break;
            default:
                UserDefaults.standard.set(20, forKey: "dealHistoryCount")
                break;
            }
        }
    }
    
    fileprivate func setNotificationsEnabled(enabled: Bool) {
        Analytics.logEvent("setNotifications", parameters: [
            "recieveNotifications": enabled
            ])
        
        if enabled {
            setupFMC()
        } else {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            UserDefaults.standard.set(false, forKey: "receiveNotifications")
            UserDefaults.standard.set(false, forKey: "remindForMeh")
            UserDefaults.standard.set("6:00 PM", forKey: "reminderTime")
            setSectionOneRows()
            Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").removeValue()
        }
    }
    
    fileprivate func setMehRemindersEnabled(enabled: Bool) {
        if UserDefaults.standard.bool(forKey: "receiveNotifications") == true {
            let reminderTimeAsString: String = UserDefaults.standard.string(forKey: "reminderTime") ?? "6:00 PM"
            Analytics.logEvent("setMehReminders", parameters: [
                "recieveNotifications": enabled,
                "time": reminderTimeAsString
                ])
            
            UserDefaults.standard.set(enabled, forKey: "remindForMeh")
            let center = UNUserNotificationCenter.current()
            
            if enabled {
                let content = UNMutableNotificationContent()
                content.title = "Today's deal is almost over!"
                content.body = "Don't forget to press the meh button today"
                content.sound = UNNotificationSound.default()
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.defaultDate = Date(timeIntervalSinceReferenceDate: 0)
                guard let testDate = formatter.date(from: reminderTimeAsString) else { return }
                let triggerDate = Calendar.current.dateComponents([.hour,.minute,.second], from: testDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                let request = UNNotificationRequest(identifier: "com.kirinpatel.meh", content: content, trigger: trigger)
                center.add(request, withCompletionHandler: { (error) in
                    print("hello?")
                    if error != nil {
                        UserDefaults.standard.set(false, forKey: "remindForMeh")
                        UserDefaults.standard.set("6:00 PM", forKey: "reminderTime")
                        self.setSectionOneRows()
                        let alert = UIAlertController(title: "An Error Occurred", message: "An unexpected error occurred while enabling notifications.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default))
                        self.present(alert, animated: true)
                    }
                })
            } else {
                center.removeAllPendingNotificationRequests()
                UserDefaults.standard.set("6:00 PM", forKey: "reminderTime")
            }
            setSectionOneRows()
        } else if enabled == true {
            let alert = UIAlertController(title: "Notifications Must Be Enabled", message: "In order to receive notifications to press meh for a deal, you must have notifications enabled!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
    }
    
    fileprivate func displayDatabaseErrorAlert(receiveNotifications: Bool) {
        let alert = UIAlertController(title: "Notification Settings Error", message: "Your notifications are \(receiveNotifications ? "not" : "") enabled in the app but are in our database. Would you still like to recieve notifications?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
            Analytics.logEvent("setNotifications", parameters: [
                "recieveNotifications": true,
                "error": "Was not set in database."
                ])
            self.setupFMC()
        })
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: { _ in
            Analytics.logEvent("setNotifications", parameters: [
                "recieveNotifications": false,
                "error": "Was not set in database."
                ])
            UserDefaults.standard.set(false, forKey: "receiveNotifications")
            Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").removeValue()
        })

        alert.addAction(yesAction)
        alert.addAction(noAction)

        present(alert, animated: true)
    }
    
    fileprivate func setupFMC() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
            if error == nil {
                if granted {
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                        UserDefaults.standard.set(true, forKey: "receiveNotifications")
                        self.setSectionOneRows()
                        Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").setValue(true)
                    })
                } else {
                    UserDefaults.standard.set(false, forKey: "receiveNotifications")
                    Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").removeValue()
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "Notification Settings Error", message: "Notification permissions are required to receive notifications when new deals start. You can enable this in settings.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                            self.setSectionOneRows()
                        })
                        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                        })
                        self.present(alert, animated: true)
                    })
                }
            } else {
                UserDefaults.standard.set(false, forKey: "receiveNotifications")
                Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").removeValue()
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Notification Settings Error", message: "Notification were unable to be enabled.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true)
                })
            }
        })
    }
    
    fileprivate func loadInterstitial() -> GADInterstitial {
        Analytics.logEvent("loaded_ad", parameters: [
            "type":"interstitial",
            "location":"SettingsViewController"
            ])
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-9026572937829340/2237689912")
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }
    
    fileprivate func displayAd() {
        if interstitial.isReady {
            Analytics.logEvent("viewed_ad", parameters: [
                "type":"interstitial",
                "location":"SettingsViewController",
                "successful": true
                ])
            interstitial.present(fromRootViewController: self)
        } else {
            Analytics.logEvent("viewed_ad", parameters: [
                "type":"interstitial",
                "location":"SettingsViewController",
                "successful": false
                ])
            let alert = UIAlertController(title: "Unable To Load Ad",
                                          message: "The ad was unable to load. Thank you for showing your support! You can try again after a few seconds if you would like, but it is not necessary.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
                self.setSectionOneRows()
            })
            present(alert, animated: true)
        }
    }
    
    func openTimePicker()  {
        effectView.frame = CGRect(x: 0.0,
                                  y: (view.frame.height / 3) * 2,
                                  width: view.frame.width,
                                  height: view.frame.height / 3)
        timePicker.frame = CGRect(x: 0.0,
                                  y: 30.0,
                                  width: effectView.frame.width,
                                  height: effectView.frame.height - 30.0)
        closeButton.frame = CGRect(x: effectView.frame.width - 65.0,
                                   y: 0.0,
                                   width: 65.0,
                                   height: 30.0)
        view.addSubview(effectView)
        effectView.contentView.addSubview(timePicker)
        effectView.contentView.addSubview(closeButton)
        setSectionOneRows()
    }
    
    @objc func startTimeDiveChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let time = formatter.string(from: sender.date)
        UserDefaults.standard.set(time, forKey: "reminderTime")
        setMehRemindersEnabled(enabled: true)
        setSectionOneRows()
    }
    
    @objc func closeTimePicker() {
        effectView.removeFromSuperview()
        timePicker.removeFromSuperview()
        closeButton.removeFromSuperview()
        setSectionOneRows()
    }
    
    fileprivate func setSectionOneRows() {
        notificationSwitch = SwitchRow(title: "Receive Notifications",
                                       switchValue: UserDefaults.standard.bool(forKey: "receiveNotifications"),
                                       action: didToggleSelection())
        
        mehReminderSwitch = SwitchRow(title: "Get Reminded to Press Meh",
                                      switchValue: UserDefaults.standard.bool(forKey: "remindForMeh"),
                                      action: didToggleSelection())
        let reminderTime: String = UserDefaults.standard.string(forKey: "reminderTime") ?? "6:00 PM"
        let mehReminderTime = NavigationRow(title: "Notificatiton Reminder Time",
                                            subtitle: .rightAligned(reminderTime),
                                            action: { _ in self.openTimePicker() })
        
        var sectionOneRows: [Row & RowStyle] = [ notificationSwitch ]
        if UserDefaults.standard.bool(forKey: "receiveNotifications") {
            sectionOneRows.append(mehReminderSwitch)
        }
        if UserDefaults.standard.bool(forKey: "remindForMeh") {
            sectionOneRows.append(mehReminderTime)
        }
        
        var notificationsFooter = ""
        if sectionOneRows.count > 1 {
            notificationsFooter = "Mehathons are currently not supported by the reminder notifications. This is a limitation of meh.com, please comment on their forms, requesting them to add support for end dates on deals."
            if mehReminderSwitch.switchValue {
                notificationsFooter += "\n\nDaily meh deals reset at 12 AM EST (4 AM UTC)."
            }
        }
        
        tableContents = [
            Section(title: "Notifications",
                    rows: sectionOneRows,
                    footer: notificationsFooter),
            Section(title: "Deal History",
                    rows: [
                        SwitchRow(title: "Load images",
                                  switchValue: UserDefaults.standard.bool(forKey: "loadHistoryImages"),
                                  action: didToggleSelection()),
                        ],
                    footer: "Please note, loading images has significantly high network usage and should not be used by users with limited data/bandwidth cellular plans."),
            radios,
            Section(title: "Support the Developer",
                    rows: [
                        NavigationRow(title: "Watch Ad",
                                      subtitle: .belowTitle("Help pay for a coffee"),
                                      action: { _ in self.displayAd() }),
                        ],
                    footer: "Watch an ad that helps the developer (Kirin Patel) cover development costs and time. This is not required and is only something that should be done by users who are willing to watch ads to support the developer (Kirin Patel).")
        ]
    }
    
    fileprivate func showSimpleAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            if let completion = completion {
                completion()
            }
        })
        present(alert, animated: true)
    }
}

extension SettingsViewController: GADInterstitialDelegate {
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        Analytics.logEvent("received_ad", parameters: [
            "type":"interstitial",
            "location":"SettingsViewController"
            ])
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = loadInterstitial()
    }
}
