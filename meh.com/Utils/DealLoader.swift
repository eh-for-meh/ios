//
//  DealLoader.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import FirebaseAnalytics
import UIKit

protocol DealUpdateListener {
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
    
    func loadPreviousDeals(completion: @escaping (Result<[PreviousDeal], Error>) -> Void) {
        if let url = URL(string: "https://meh.com/forum/topics.json?category=deals&sort=date-created") {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                Analytics.logEvent("loadPreviousDeals", parameters: ["eventType": "initiated"])
                if let error = error {
                    Analytics.logEvent("loadPreviousDeals", parameters: ["eventType": "failed", "reason": "network"])
                    completion(.failure(error))
                }
                
                if let data = data {
                    do {
                        let previousDeals = try JSONDecoder().decode([PreviousDeal].self, from: data)
                        Analytics.logEvent("loadPreviousDeals", parameters: ["eventType": "success"])
                        completion(.success(previousDeals))
                    } catch let error {
                        Analytics.logEvent("loadPreviousDeals", parameters: ["eventType": "failed", "reason": "decode"])
                        completion(.failure(error))
                    }
                }
            }
            urlSession.resume()
        }
    }
    
    @objc private func objcLoadCurrentDeal() {
        loadCurrentDeal()
    }
}
