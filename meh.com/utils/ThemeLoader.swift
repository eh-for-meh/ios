//
//  ThemeLoader.swift
//  meh.com
//
//  Created by Kirin Patel on 5/4/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import FirebaseDatabase

@objc class ThemeLoader: NSObject {
    
    @objc static let shared = ThemeLoader()
    
    @objc func loadTheme(completion: @escaping (_ theme: Theme) -> Void) {
        Database.database().reference(withPath: "currentDeal/deal/theme").observeSingleEvent(of: .value) { snapshot in
            if let theme = self.convertDataSnapshotToTheme(snapshot: snapshot) {
                completion(theme)
            }
        }
    }
    
    @objc func loadTheme(forPreviousDeal: String, completion: @escaping (_ theme: Theme) -> Void) {
        Database.database().reference(withPath: "previousDeal/\(forPreviousDeal)/deal/theme").observeSingleEvent(of: .value, with: { snapshot in
            if let theme = self.convertDataSnapshotToTheme(snapshot: snapshot, dealId: forPreviousDeal) {
                completion(theme)
            }
        })
    }
    
    fileprivate func convertDataSnapshotToTheme(snapshot: DataSnapshot, dealId: String = "current") -> Theme? {
        guard let value = snapshot.value as? [String: Any] else { return nil }
        do {
            let json: Data = try JSONSerialization.data(withJSONObject: value, options: [])
            let theme: Theme = try JSONDecoder().decode(Theme.self, from: json)
            return theme
        } catch let error {
            Analytics.logEvent("theme_load_failed", parameters: ["deal": dealId])
            print("Error loading theme: \(error)")
        }
        return nil
    }
}
