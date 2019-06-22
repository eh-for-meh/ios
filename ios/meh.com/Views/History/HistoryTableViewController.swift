//
//  HistoryTableViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import StoreKit
import FirebaseAnalytics
import FirebaseDatabase
import Nuke

class HistoryTableViewController: UITableViewController {
    
    let cellIdentifier = "previousDealCell"
    let reviewAskInterval: Double = 86400.0
    let lastTimeReviewAsked = UserDefaults.standard.double(forKey: "lastTimeReviewWasAsked")
    var previousDeals = [Deal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        navigationItem.title = "History"
        tableView.separatorStyle = .none
        
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        let backButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(handleBack))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
        
        loadData()
        
        if lastTimeReviewAsked == 0.0 || NSDate().timeIntervalSince1970 - lastTimeReviewAsked > reviewAskInterval {
            UserDefaults.standard.set(NSDate().timeIntervalSince1970, forKey: "lastTimeReviewWasAsked")
            SKStoreReviewController.requestReview()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousDeals.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dealView = MainViewController()
        let previousDeal = previousDeals[indexPath.row]
        dealView.deal = previousDeal
        dealView.view.backgroundColor = previousDeal.theme.backgroundColor
        dealView.modalPresentationStyle = .currentContext
        dealView.modalTransitionStyle = .crossDissolve
        present(dealView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HistoryTableViewCell
        
        cell.deal = previousDeals[indexPath.row]
        if UserDefaults.standard.bool(forKey: "loadHistoryImages") {
            loadImage(deal: cell.deal, completion: { image in
                if cell.deal.id == self.previousDeals[indexPath.row].id {
                    cell.dealImage = image
                }
            })
        }
        
        return cell
    }
    
    @objc func handleBack() {
        dismiss(animated: true)
    }
    
    fileprivate func loadData() {
        if let toLast = UserDefaults.standard.object(forKey: "dealHistoryCount") as? Int {
            Database.database().reference().child("previousDeal").queryOrdered(byChild: "time").queryLimited(toLast: UInt(toLast) + 1).observeSingleEvent(of: .value) { snapshot in
                self.previousDeals.removeAll()
                
                for child in snapshot.children.allObjects.reversed().dropFirst() {
                    let childSnapshot = child as! DataSnapshot
                    
                    DealLoader.sharedInstance.loadDeal(forDeal: childSnapshot.key, completion: { deal in
                        self.previousDeals.append(deal)
                        
                        self.tableView.reloadData()
                    })
                }
            }
        } else {
            let toLast: UInt = UIDevice.current.userInterfaceIdiom == .pad ? 51 : 21
            
            Database.database().reference().child("previousDeal").queryOrdered(byChild: "time").queryLimited(toLast: toLast).observeSingleEvent(of: .value) { snapshot in
                self.previousDeals.removeAll()
                
                for child in snapshot.children.allObjects.reversed().dropFirst() {
                    let childSnapshot = child as! DataSnapshot
                    
                    DealLoader.sharedInstance.loadDeal(forDeal: childSnapshot.key, completion: { deal in
                        self.previousDeals.append(deal)
                        
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    fileprivate func loadImage(deal: Deal, loadLast: Bool = false, completion: @escaping (_ image: UIImage) -> Void) {
        if let url = loadLast ? deal.photos.last : deal.photos.first {
            if let image = URL(string: url.absoluteString.replacingOccurrences(of: "http", with: "https")) {
                ImagePipeline.shared.loadImage(
                    with: image,
                    completion: { response, _ in
                        if response != nil, let image = response?.image {
                            completion(image)
                        } else {
                            self.loadImage(deal: deal,
                                           loadLast: true,
                                           completion: completion)
                        }
                })
            }
        }
    }
}
