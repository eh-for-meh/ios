//
//  MainViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 5/5/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit

@objc class MainViewController: UIViewController {
    
    @objc var theme: Theme! {
        didSet {
            if let backgroundColorString = theme.backgroundColor {
                view.backgroundColor = UIColor.color(fromHexString: backgroundColorString)
            }
        }
    }
}
