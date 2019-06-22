//
//  MainViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 7/17/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import SafariServices
import FirebaseAnalytics
import FirebaseDatabase

class MainViewController: UIViewController {
    
    var hasAddedBottomSheet: Bool = false
    var deal: Deal? {
        didSet {
            if let deal = deal {
                dealView.deal = deal
                bottomSheet.deal = deal
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.backgroundColor = deal.theme.backgroundColor
                    self.optionsStackView.backgroundColor = deal.theme.dark ? .white : .black
                    self.settingsButton.alpha = 1
                    self.settingsButton.tintColor = deal.theme.accentColor
                    self.historyButton.alpha = 1
                    self.historyButton.tintColor = deal.theme.accentColor
                    self.closeButton.alpha = 1
                    self.closeButton.tintColor = deal.theme.accentColor
                    self.shareButton.alpha = 1
                    self.shareButton.tintColor = deal.theme.accentColor
                    self.viewForumButton.alpha = 1
                    self.viewForumButton.tintColor = deal.theme.accentColor
                })
            }
        }
    }
    
    let bottomSheet = BottomSheetViewController()
    let dealView = DealViewController()
    
    let optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    let settingsButton: UIButton = {
        let button = UIButton(type: .infoLight)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        button.addTarget(self, action: #selector(handleViewSettings), for: .touchUpInside)
        return button
    }()
    
    let historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0
        button.setTitle("History", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
        button.addTarget(self, action: #selector(handleViewHistory), for: .touchUpInside)
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0
        button.setTitle("Share", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
        button.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        return button
    }()
    
    let viewForumButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0
        button.setTitle("Forum", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
        button.addTarget(self, action: #selector(handleViewForum), for: .touchUpInside)
        return button
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDealView()
        addBottomSheet()
        setupView()
        
        if deal == nil {
            setupDealObserver()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let deal = deal {
            return deal.theme.dark ? .lightContent : .default
        }
        
        return .default
    }
    
    @objc func handleViewHistory() {
        if let deal = deal {
            Analytics.logEvent("viewedHistory", parameters: [:])
            let historyView = HistoryNavigationViewController()
            
            historyView.theme = deal.theme
            
            historyView.modalPresentationStyle = .fullScreen
            historyView.modalTransitionStyle = .crossDissolve
            
            present(historyView, animated: true)
        }
    }
    
    @objc func handleShare() {
        if let deal = deal {
            let shareContent = "Chech out this deal from the eh for meh app. \(deal.url)"
            Analytics.logEvent("shared", parameters: ["deal": deal.id])
            let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
            present(activityViewController, animated: true)
        }
    }
    
    @objc func handleViewForum() {
        if let deal = deal {
            if let topic = deal.topic {
                Analytics.logEvent("viewedForum", parameters: ["deal": deal.id])
                let view = SFSafariViewController(url: topic.url)
                present(view, animated: true)
            }
        }
    }
    
    @objc func handleClose() {
        dismiss(animated: true)
    }
    
    @objc func handleViewSettings() {
        if let deal = deal {
            Analytics.logEvent("viewedSettings", parameters: [:])
            present(SettingsNavigationViewController(), animated: true)
        }
    }
    
    fileprivate func setupDealObserver() {
        DealLoader.sharedInstance.loadCurrentDeal(completion: { deal in
            self.deal = deal
        })
    }
    
    fileprivate func addBottomSheet() {
        if hasAddedBottomSheet { return }
        
        addChildViewController(bottomSheet)
        view.addSubview(bottomSheet.view)
        bottomSheet.didMove(toParentViewController: self)
        bottomSheet.view.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.maxY),
                                        size: CGSize(width: view.frame.width, height: view.frame.height))
    }
    
    fileprivate func setupDealView() {
        addChildViewController(dealView)
        view.addSubview(dealView.view)
        dealView.didMove(toParentViewController: self)
        dealView.view.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                                     size: CGSize(width: view.frame.width, height: view.frame.height - 100))
    }
    
    fileprivate func setupView() {
        view.addSubview(optionsStackView)
        optionsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        optionsStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        if deal == nil {
            view.addSubview(settingsButton)
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
            settingsButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            
            optionsStackView.addArrangedSubview(historyButton)
        } else {
            view.addSubview(closeButton)
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            closeButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        }
        
        optionsStackView.addArrangedSubview(shareButton)
        optionsStackView.addArrangedSubview(viewForumButton)
    }
}
