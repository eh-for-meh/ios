//
//  DealHistoryLoadImagesTableViewCell.swift
//  meh.com
//
//  Created by Kirin Patel on 2/7/21.
//  Copyright © 2021 Kirin Patel. All rights reserved.
//

import UIKit

class DealHistoryLoadImagesTableViewCell: UITableViewCell {
    
    @IBOutlet var toggle: UISwitch?
    
    @IBAction func toggleValueChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "loadHistoryImages")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        toggle?.isOn = UserDefaults.standard.bool(forKey: "loadHistoryImages")
    }
}
