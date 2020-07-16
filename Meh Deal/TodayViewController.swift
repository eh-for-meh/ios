//
//  TodayViewController.swift
//  Meh Deal
//
//  Created by Kirin Patel on 1/20/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var openInAppButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var isLoadingDeal: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        loadData()
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func viewButtonTouched(_ sender: UIButton) {
        if let url = URL(string: "meh:") {
            self.extensionContext!.open(url, completionHandler: nil)
        }
    }
    
    @IBAction func buyButtonTouched(_ sender: UIButton) {
        if let url = URL(string: "https://meh.com/account/signin?returnurl=https%3A%2F%2Fmeh.com%2F%23checkout") {
            self.extensionContext!.open(url, completionHandler: nil)
        }
    }
    
    fileprivate func loadData() {
        print("Loading deal...")
        if isLoadingDeal {
            print("Stopping, load already in progress!")
            return
        }
        DispatchQueue.main.async {
            self.openInAppButton.isHidden = true
            self.buyButton.isHidden = true
        }
        isLoadingDeal = true
        let url = URL(string: "https://meh-app.firebaseio.com/currentDeal/deal.json")!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                return self.isLoadingDeal = false
            }
            do {
                let deal = try JSONDecoder().decode(Deal.self, from: data)
                print("Deal loaded!")
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.titleLabel.text = deal.title
                    self.priceLabel.text = deal.price
                    self.openInAppButton.isHidden = false
                    self.buyButton.isHidden = false
                }
                self.isLoadingDeal = false
            } catch let jsonError {
                print("Error serializing json: ", jsonError)
                self.isLoadingDeal = false
            }
        }
        task.resume()
    }
}
