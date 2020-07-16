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
    var previousDeals: [PreviousDeal] = []
    
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
        if let url = URL(string: previousDeal.url) {
            let view = SFSafariViewController(url: url)
            present(view, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HistoryTableViewCell
        
        let previousDeal = previousDeals[indexPath.row]
        cell.deal = previousDeal
        if UserDefaults.standard.bool(forKey: "loadHistoryImages") {
            loadImage(url: previousDeal.photo, completion: { image in
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
        let defaultToLast: Int = UIDevice.current.userInterfaceIdiom == .pad ? 51 : 21
        let toLast: Int = UserDefaults.standard.object(forKey: "dealHistoryCount") as? Int ?? defaultToLast
        DealLoader.sharedInstance.loadPreviousDeals { result in
            switch result {
            case .success(let previousDeals):
                let visibleDeals = previousDeals.dropFirst().dropLast(previousDeals.count - toLast - 1)
                visibleDeals.forEach({ self.previousDeals.append($0) })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                break
            case .failure(let error):
                // TODO
                break
            }
        }
    }
    
    fileprivate func loadImage(url: String, completion: @escaping (_ image: UIImage) -> Void) {
        if let image = URL(string: url.replacingOccurrences(of: "http://", with: "https://")) {
            ImagePipeline.shared.loadImage(
                with: image,
                completion: { response, _ in
                    if response != nil, let image = response?.image {
                        completion(image)
                    }
            })
        }
    }
}
