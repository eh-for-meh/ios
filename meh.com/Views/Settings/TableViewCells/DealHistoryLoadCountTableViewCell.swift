//
//  DealHistoryLoadCountTableViewCell.swift
//  meh.com
//
//  Created by Kirin Patel on 2/7/21.
//  Copyright © 2021 Kirin Patel. All rights reserved.
//

import UIKit

class DealHistoryLoadCountTableViewCell: UITableViewCell {

    @IBOutlet var segment: UISegmentedControl?
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        let dealHistoryCount = segment?.selectedSegmentIndex == 0 ? 25 : 100
        UserDefaults.standard.set(dealHistoryCount, forKey: "dealHistoryCount")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        segment?.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "dealHistoryCount") == 100 ? 1 : 0
    }
}
