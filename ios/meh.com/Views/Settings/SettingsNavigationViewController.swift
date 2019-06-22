//
//  SettingsNavigationViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 10/15/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class SettingsNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
        
        pushViewController(SettingsViewController(), animated: true)
    }
}
