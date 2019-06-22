//
//  File.swift
//  meh.com
//
//  Created by Kirin Patel on 7/21/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "eh for meh"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupView()
        loadMainViewController()
    }
    
    fileprivate func setupView() {
        view.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    fileprivate func loadMainViewController() {
        ThemeLoader.sharedInstance.loadTheme(completion: { theme in
            UIView.animate(withDuration: 0.5, animations: {
                self.view.backgroundColor = theme.backgroundColor
                self.titleLabel.alpha = 0
            }, completion: { _ in
                let mainViewController = MainViewController()
                mainViewController.view.backgroundColor = theme.backgroundColor
                
                self.present(mainViewController, animated: false)
            })
        })
    }
}
