//
//  DealLoader.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics
import FirebaseDatabase

class DealLoader {
    
    static let sharedInstance = DealLoader()
    
    func loadCurrentDeal(completion: @escaping (_ deal: Deal) -> Void) {
        ThemeLoader.sharedInstance.setupThemeListener { theme in
            Database.database().reference().child("currentDeal/deal").observeSingleEvent(of: .value) { snapshot in
                let deal = self.getDealFromSnapshot(theme: theme, snapshot: snapshot)
                Analytics.logEvent("loadDeal", parameters: [
                    "deal": deal.id
                    ])
                completion(deal)
            }
        }
    }

    func loadDeal(forDeal id: String, completion: @escaping (_ deal: Deal) -> Void) {
        ThemeLoader.sharedInstance.loadTheme(forDeal: id) { theme in
            Database.database().reference().child("previousDeal/\(id)").observeSingleEvent(of: .value, with: { snapshot in
                let deal = self.getDealFromSnapshot(theme: theme, snapshot: snapshot.childSnapshot(forPath: "deal"))
                deal.isPreviousDeal = true
                
                if snapshot.childSnapshot(forPath: "time").exists(), let date = snapshot.childSnapshot(forPath: "time").value as? Double {
                    deal.date = Date(timeIntervalSince1970: TimeInterval(date / 1000))
                }
                Analytics.logEvent("loadPreviousDeal", parameters: [
                    "deal": deal.id
                    ])
                completion(deal)
            })
        }
    }
    
    private func getDealFromSnapshot(theme: Theme, snapshot: DataSnapshot) -> Deal {
        let id = snapshot.childSnapshot(forPath: "id").value as? String ?? ""
        let features = snapshot.childSnapshot(forPath: "features").value as? String ?? ""
        let specifications = snapshot.childSnapshot(forPath: "specifications").value as? String ?? ""
        let title = snapshot.childSnapshot(forPath: "title").value as? String ?? ""
        let url = URL(string: snapshot.childSnapshot(forPath: "url").value as? String ?? "https://meh.com")
        
        let storyTitle = snapshot.childSnapshot(forPath: "story/title").value as? String ?? ""
        let storyBody = snapshot.childSnapshot(forPath: "story/body").value as? String ?? ""
        let story = Story(title: storyTitle, body: storyBody)
        
        let deal = Deal(id: id,
                        title: title,
                        features: features,
                        specifications: specifications,
                        story: story,
                        theme: theme,
                        url: url!)
        
        
        deal.items.append(contentsOf: loadDealItems(objects: snapshot.childSnapshot(forPath: "items").children.allObjects))
        deal.photos.append(contentsOf: loadDealPhotos(objects: snapshot.childSnapshot(forPath: "photos").children.allObjects))
        
        if snapshot.childSnapshot(forPath: "soldOutAt").exists() {
            deal.soldOut = true
        } else if (snapshot.childSnapshot(forPath: "launches").exists()) {
            let itemCount = snapshot.childSnapshot(forPath: "items").childrenCount
            let soldOutCount = snapshot.childSnapshot(forPath: "launches").childrenCount
            deal.soldOut = itemCount == soldOutCount
        }
        
        if snapshot.childSnapshot(forPath: "topic").exists() {
            let topicId = snapshot.childSnapshot(forPath: "topic/id").value as? String ?? ""
            let topicURL = URL(string: snapshot.childSnapshot(forPath: "topic/url").value as? String ?? "")
            
            if let url = topicURL {
                deal.topic = Topic(id: topicId, url: url)
            }
        }
        
        return deal
    }
    
    private func loadDealItems(objects: [Any]) -> [Item] {
        var items = [Item]()
        
        for child in objects {
            if let childSnapshot = child as? DataSnapshot {
                let itemId = childSnapshot.childSnapshot(forPath: "id").value as? String ?? ""
                let itemCondition = childSnapshot.childSnapshot(forPath: "condition").value as? String ?? ""
                let itemPrice = childSnapshot.childSnapshot(forPath: "price").value as? CGFloat ?? 0.0
                
                items.append(Item(id: itemId, condition: itemCondition, price: itemPrice))
            }
        }
        
        return items
    }
    
    private func loadDealPhotos(objects: [Any]) -> [URL] {
        var photos = [URL]()
        
        for child in objects {
            let childSnapshot = child as! DataSnapshot
            
            photos.append(URL(string: childSnapshot.value as! String)!)
        }
        
        return photos
    }
}
