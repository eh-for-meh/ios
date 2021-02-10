//
//  DealLoader.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import FirebaseAnalytics
import FirebaseDatabase
import UIKit

protocol DealUpdateListener {
    var id: String { get }
    func dealUpdateInitiated()
    func dealUpdated()
    func dealUpdateFailed(error: Error)
}

class DealLoader {
    
    static let shared = DealLoader()
    
    private var databaseURL: String?
    var deal: Deal?
    private var listeners: [DealUpdateListener] = []
    private var timer: Timer?
    
    init() {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            databaseURL = dict["DATABASE_URL"] as? String
        }
        loadCurrentDeal()
        timer = Timer.scheduledTimer(timeInterval: 60,
                             target: self,
                             selector: #selector(self.objcLoadCurrentDeal),
                             userInfo: nil,
                             repeats: true)
    }
    
    deinit {
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    func addListener(listener: DealUpdateListener) {
        listeners.append(listener)
    }
    
    func removeListener(listener: DealUpdateListener) {
        listeners = listeners.filter { $0.id != listener.id }
    }
    
    func loadCurrentDeal(completion: @escaping (Result<Deal, Error>) -> Void = { _ in }) {
        guard let databaseURL = databaseURL else { return }
        Analytics.logEvent("loadCurrentDeal", parameters: ["eventType": "initiated"])
        listeners.forEach({ $0.dealUpdateInitiated() })
        if let url = URL(string: "\(databaseURL)/currentDeal/deal.json") {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    Analytics.logEvent("loadCurrentDeal", parameters: ["eventType": "failed", "reason": "network"])
                    completion(.failure(error))
                    self.listeners.forEach({ $0.dealUpdateFailed(error: error) })
                }
                
                if let data = data {
                    do {
                        let deal = try JSONDecoder().decode(Deal.self, from: data)
                        self.deal = deal
                        self.listeners.forEach({ $0.dealUpdated() })
                        Analytics.logEvent("loadCurrentDeal", parameters: ["eventType": "success"])
                        completion(.success(deal))
                    } catch let error {
                        Analytics.logEvent("loadCurrentDeal", parameters: ["eventType": "failed", "reason": "decode"])
                        completion(.failure(error))
                        self.listeners.forEach({ $0.dealUpdateFailed(error: error) })
                    }
                }
            }
            urlSession.resume()
        }
    }
    
    func loadPreviousDeals(completion: @escaping (Result<[Deal], Error>) -> Void) {
        let toLast: UInt = UInt(UserDefaults.standard.object(forKey: "dealHistoryCount") as? Int ?? 25)
        print(toLast)
        let ref = Database.database().reference().child("previousDeal")
        let query = ref.queryOrdered(byChild: "time").queryLimited(toLast: toLast)
        query.observeSingleEvent(of: .value) { snapshot in
            var previousDeals: [Deal] = []
            for child in snapshot.children.allObjects.reversed().dropFirst() {
                if let childSnapshot = child as? DataSnapshot {
                    do {
                        let endTime = childSnapshot.childSnapshot(forPath: "time").value as? Double ?? 0
                        let endDate = Date(timeIntervalSince1970: endTime / 1000)
                        let dealSnapshot = childSnapshot.childSnapshot(forPath: "deal")
                        let data = try JSONSerialization.data(withJSONObject: dealSnapshot.value as Any)
                        var deal = try JSONDecoder().decode(Deal.self, from: data)
                        deal.date = endDate
                        previousDeals.append(deal)
                    } catch let error {
                        completion(.failure(error))
                    }
                }
            }
            completion(.success(previousDeals))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
    
    @objc private func objcLoadCurrentDeal() {
        loadCurrentDeal()
    }
}
