//
//  MainViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 7/17/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import SafariServices

class MainViewController: UIViewController {
    
    var hasAddedBottomSheet: Bool = false
    var deal: Deal? {
        didSet {
            if let deal = deal {
                dealView.deal = deal
                bottomSheet.deal = deal
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.backgroundColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
                    self.optionsStackView.backgroundColor = deal.theme.foreground == "dark" ? .white : .black
                    self.settingsButton.alpha = 1
                    self.settingsButton.tintColor = UIColor.color(fromHexString: deal.theme.accentColor)
                    self.historyButton.alpha = 1
                    self.historyButton.tintColor = UIColor.color(fromHexString: deal.theme.accentColor)
                    self.closeButton.alpha = 1
                    self.closeButton.tintColor = UIColor.color(fromHexString: deal.theme.accentColor)
                    self.shareButton.alpha = 1
                    self.shareButton.tintColor = UIColor.color(fromHexString: deal.theme.accentColor)
                    self.viewForumButton.alpha = 1
                    self.viewForumButton.tintColor = UIColor.color(fromHexString: deal.theme.accentColor)
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
        DealLoader.shared.addListener(listener: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let deal = deal else { return .default }
        return deal.theme.foreground == "dark" ? .lightContent : .default
    }
    
    @objc func handleViewHistory() {
        guard deal != nil else { return }
        let historyView = HistoryNavigationViewController()
        historyView.modalPresentationStyle = .fullScreen
        historyView.modalTransitionStyle = .crossDissolve
        present(historyView, animated: true)
    }
    
    @objc func handleShare() {
        guard let deal = deal else { return }
        let shareContent = "Chech out this deal from the eh for meh app. \(deal.url)"
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    @objc func handleViewForum() {
        guard let deal = deal, let topic = deal.topic else { return }
        let view = SFSafariViewController(url: topic.url)
        present(view, animated: true)
    }
    
    @objc func handleClose() {
        dismiss(animated: true)
    }
    
    @objc func handleViewSettings() {
        guard deal != nil else { return }
        present(SettingsNavigationViewController(), animated: true)
    }
    
    fileprivate func addBottomSheet() {
        guard hasAddedBottomSheet == false else { return }
        addChild(bottomSheet)
        view.addSubview(bottomSheet.view)
        bottomSheet.didMove(toParent: self)
        bottomSheet.view.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.maxY),
                                        size: CGSize(width: view.frame.width, height: view.frame.height))
    }
    
    fileprivate func setupDealView() {
        addChild(dealView)
        view.addSubview(dealView.view)
        dealView.didMove(toParent: self)
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

extension MainViewController: DealUpdateListener {
    var id: String {
        get {
            "MainViewController"
        }
    }
    
    
    func dealUpdateInitiated() {
        // TODO
    }
    
    func dealUpdated() {
        if let deal = DealLoader.shared.deal {
            DispatchQueue.main.async {
                self.deal = deal
            }
        }
    }
    
    func dealUpdateFailed(error: Error) {
        // TODO
    }
}
