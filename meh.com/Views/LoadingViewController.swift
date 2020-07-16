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
        setupView()
        DealLoader.shared.addListener(listener: self)
    }
    
    fileprivate func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension LoadingViewController: DealUpdateListener {
    func dealUpdateInitiated() {
        // TODO
    }
    
    func dealUpdated() {
        if let deal = DealLoader.shared.deal {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.backgroundColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
                    self.titleLabel.alpha = 0
                }, completion: { _ in
                    let mainViewController = MainViewController()
                    mainViewController.view.backgroundColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
                    mainViewController.modalPresentationStyle = .fullScreen
                    self.present(mainViewController, animated: false) {
                        mainViewController.deal = deal
                    }
                })
            }
        }
    }
    
    func dealUpdateFailed(error: Error) {
        // TODO
    }
}
