//
//  HistoryTableViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import SafariServices
import StoreKit
import Nuke

class HistoryTableViewController: UITableViewController {
    
    let cellIdentifier = "previousDealCell"
    let reviewAskInterval: Double = 86400.0
    let lastTimeReviewAsked = UserDefaults.standard.double(forKey: "lastTimeReviewWasAsked")
    var previousDeals: [Deal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = "History"
        
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
        let previousDeal = previousDeals[indexPath.row]
        let previousDealViewController = MainViewController()
        previousDealViewController.deal = previousDeal
        previousDealViewController.modalPresentationStyle = .fullScreen
        previousDealViewController.modalTransitionStyle = .crossDissolve
        present(previousDealViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HistoryTableViewCell
        
        cell.deal = previousDeals[indexPath.row]
        
        return cell
    }
    
    @objc func handleBack() {
        dismiss(animated: true)
    }
    
    fileprivate func loadData() {
        DealLoader.shared.loadPreviousDeals { result in
            switch result {
            case .success(let previousDeals):
                self.previousDeals = previousDeals
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                break
            case .failure(_):
                // TODO
                print("FAILURE")
                print(result)
                break
            }
        }
    }
}
