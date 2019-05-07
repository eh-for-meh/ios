//
//  DealLoader.swift
//  meh.com
//
//  Created by Kirin Patel on 5/7/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import FirebaseDatabase

class DealLoader {
    
    static let shared = DealLoader()
    
    func loadDeal(completion: @escaping (_ deal: Deal) -> Void) {
        Database.database().reference(withPath: "currentDeal/deal").observeSingleEvent(of: .value) { snapshot in
            if let deal = self.convertDataSnapshotToDeal(snapshot: snapshot) {
                completion(deal)
            }
        }
    }
    
    fileprivate func convertDataSnapshotToDeal(snapshot: DataSnapshot, dealId: String = "current") -> Deal? {
        guard let value = snapshot.value as? [String: Any] else { return nil }
        do {
            let json: Data = try JSONSerialization.data(withJSONObject: value, options: [])
            let deal: Deal = try JSONDecoder().decode(Deal.self, from: json)
            return deal
        } catch let error {
            Analytics.logEvent("deal_load_failed", parameters: ["deal": dealId])
            print("Error loading theme: \(error)")
        }
        return nil
    }
}
