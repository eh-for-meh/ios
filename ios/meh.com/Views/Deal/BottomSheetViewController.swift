//
//  BottomSheetViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 9/23/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import SafariServices
import FirebaseAnalytics
import GoogleMobileAds
import SwiftyMarkdown

class BottomSheetViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var deal: Deal? {
        didSet {
            animateView()
        }
    }
    var isOpen: Bool = false
    
    let cornerRadius: CGFloat = 20
    let yMin = CGFloat(100)
    let yMax = UIScreen.main.bounds.height - 100
    let yMiddle = UIScreen.main.bounds.height / 2
    let yCuttoff = UIScreen.main.bounds.height / 3
    
    let pullTab: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2.5
        view.backgroundColor = .clear
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Deal Info"
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 36, weight: .medium)
        return label
    }()
    
    let buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitle("Buy", for: .normal)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(handleBuy), for: .touchUpInside)
        button.backgroundColor = .clear
        return button
    }()
    
    let segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl()
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.insertSegment(withTitle: "Features", at: 0, animated: true)
        segmentControl.insertSegment(withTitle: "Spec", at: 1, animated: true)
        segmentControl.insertSegment(withTitle: "Story", at: 2, animated: true)
        segmentControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return segmentControl
    }()
    
    let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.backgroundColor = .clear
        return tv
    }()
    
    let specTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.backgroundColor = .clear
        tv.isHidden = true
        return tv
    }()
    
    let storyScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.backgroundColor = .clear
        scrollView.isHidden = true
        return scrollView
    }()
    
    let storyTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 36, weight: .medium)
        return label
    }()
    
    let storyTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        roundCorners()
        loadBannerView()
        setupView()
        setupGestureListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateView()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        
        let y = view.frame.minY
        var offset = descriptionTextView.contentOffset.y
        if segmentControl.selectedSegmentIndex == 1 {
            offset = specTextView.contentOffset.y
        } else if segmentControl.selectedSegmentIndex == 2 {
            offset = storyScrollView.contentOffset.y
        }
        
        if (y == yMin && offset == 0 && direction > 0) || (y == yMax) {
            descriptionTextView.isScrollEnabled = false
            specTextView.isScrollEnabled = false
            storyScrollView.isScrollEnabled = false
        } else {
            descriptionTextView.isScrollEnabled = true
            specTextView.isScrollEnabled = true
            storyScrollView.isScrollEnabled = true
        }
        
        return false
    }
    
    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let y = self.view.frame.minY
        let yPosition = y + translation.y
        
        if recognizer.state == .began {
            isOpen = yPosition < yMiddle
        }
        
        if recognizer.state == .ended
            || recognizer.state == .cancelled
            || recognizer.state == .failed {
            let newY = isOpen ? yPosition > yCuttoff - yMin ? yMax : yMin : yPosition < 2 * yCuttoff + yMin ? yMin : yMax
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1.5,
                           initialSpringVelocity: 0.25,
                           options: [
                            .curveLinear,
                            .allowUserInteraction
                            ],
                           animations: {
                            self.view.frame = CGRect(origin: CGPoint(x: 0, y: newY),
                                                     size: CGSize(width: self.view.frame.width,
                                                                  height: self.view.frame.height))
            }) { _ in
                self.isOpen = yPosition < self.yMiddle
            }
        } else {
            let newY = yPosition < yMin ? yMin : yPosition > yMax ? yMax : yPosition
            self.view.frame = CGRect(origin: CGPoint(x: 0, y: newY),
                                     size: CGSize(width: view.frame.width, height: view.frame.height))
            recognizer.setTranslation(.zero, in: view)
        }
    }
    
    @objc func handleSegmentChange() {
        switch self.segmentControl.selectedSegmentIndex {
        case 1:
            self.descriptionTextView.isHidden = true;
            self.specTextView.isHidden = false;
            self.storyScrollView.isHidden = true;
            break;
        case 2:
            self.descriptionTextView.isHidden = true;
            self.specTextView.isHidden = true;
            self.storyScrollView.isHidden = false;
            break;
        default:
            self.descriptionTextView.isHidden = false;
            self.specTextView.isHidden = true;
            self.storyScrollView.isHidden = true;
            break;
        }
    }
    
    @objc func handleBuy() {
        if let url = URL(string: "https://meh.com/account/signin?returnurl=https%3A%2F%2Fmeh.com%2F%23checkout"), let deal = deal {
            Analytics.logEvent("buy", parameters: ["deal": deal.id])
            let view = SFSafariViewController(url: url)
            present(view, animated: true)
        }
    }
    
    fileprivate func animateView() {
        if let deal = deal {
            let textColor: UIColor = deal.theme.backgroundColor
            setupDeal()
            if view.backgroundColor == .clear {
                view.backgroundColor = deal.theme.accentColor
                pullTab.backgroundColor = deal.theme.backgroundColor
                buyButton.backgroundColor = deal.theme.backgroundColor
            }
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.25,
                           options: .curveLinear,
                           animations: {
                self.view.frame = CGRect(origin: CGPoint(x: 0, y: self.yMax),
                                         size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
                self.view.backgroundColor = deal.theme.accentColor
                self.pullTab.backgroundColor = deal.theme.backgroundColor
                self.segmentControl.tintColor = deal.theme.backgroundColor
                self.segmentControl.selectedSegmentIndex = 0
                self.titleLabel.textColor = textColor
                self.buyButton.backgroundColor = deal.theme.backgroundColor
                self.buyButton.tintColor = deal.theme.accentColor
                self.buyButton.setTitleColor(deal.theme.accentColor, for: .normal)
                if deal.isPreviousDeal || deal.soldOut {
                    self.buyButton.alpha = 0
                }
                self.descriptionTextView.textColor = textColor
                self.descriptionTextView.tintColor = deal.theme.backgroundColor
                self.specTextView.textColor = textColor
                self.specTextView.tintColor = deal.theme.backgroundColor
                self.storyTitleLabel.textColor = textColor
                self.storyTextView.textColor = textColor
                self.storyTextView.tintColor = deal.theme.backgroundColor
            })
        }
    }
    
    fileprivate func roundCorners() {
        let shape = CAShapeLayer()
        shape.bounds = view.frame
        shape.position = view.center
        shape.path = UIBezierPath(roundedRect: view.bounds,
                                  byRoundingCorners: [.topLeft, .topRight],
                                  cornerRadii: CGSize(width: cornerRadius,height: cornerRadius)).cgPath
        view.layer.mask = shape
    }
    
    fileprivate func setupGestureListener() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    fileprivate func setupView() {
        view.addSubview(pullTab)
        pullTab.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        pullTab.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        pullTab.widthAnchor.constraint(equalToConstant: 40).isActive = true
        pullTab.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: pullTab.bottomAnchor, constant: 15).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        view.addSubview(buyButton)
        buyButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        buyButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        buyButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buyButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 0).isActive = true
        
        view.addSubview(bannerView)
        bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150).isActive = true
        bannerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        bannerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        view.addSubview(segmentControl)
        segmentControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 27).isActive = true
        segmentControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        segmentControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        view.addSubview(descriptionTextView)
        descriptionTextView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: bannerView.topAnchor, constant: 0).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        view.addSubview(specTextView)
        specTextView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10).isActive = true
        specTextView.bottomAnchor.constraint(equalTo: bannerView.topAnchor, constant: 0).isActive = true
        specTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        specTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        view.addSubview(storyScrollView)
        storyScrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10).isActive = true
        storyScrollView.bottomAnchor.constraint(equalTo: bannerView.topAnchor, constant: 0).isActive = true
        storyScrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        storyScrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        storyScrollView.addSubview(storyTitleLabel)
        storyTitleLabel.topAnchor.constraint(equalTo: storyScrollView.topAnchor, constant: 0).isActive = true
        storyTitleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        storyTitleLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        storyScrollView.addSubview(storyTextView)
        storyTextView.topAnchor.constraint(equalTo: storyTitleLabel.bottomAnchor, constant: 0).isActive = true
        storyTextView.bottomAnchor.constraint(equalTo: storyScrollView.bottomAnchor, constant: 0).isActive = true
        storyTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        storyTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        storyScrollView.bounds = view.bounds
        storyScrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
    }
    
    fileprivate func setupDeal() {
        if let deal = deal {
            segmentControl.selectedSegmentIndex = 0
            
            let descriptionMD = SwiftyMarkdown(string: deal.features)
            descriptionTextView.dataDetectorTypes = UIDataDetectorTypes.all
            descriptionTextView.attributedText = descriptionMD.attributedString()
            descriptionTextView.sizeToFit()
            descriptionTextView.layoutIfNeeded()
            descriptionTextView.scrollsToTop = true
            
            let specMD = SwiftyMarkdown(string: deal.specifications.replacingOccurrences(of: "\\", with: ""))
            specTextView.dataDetectorTypes = UIDataDetectorTypes.all
            specTextView.attributedText = specMD.attributedString()
            specTextView.sizeToFit()
            specTextView.layoutIfNeeded()
            specTextView.scrollsToTop = true
            
            storyTitleLabel.text = deal.story.title
            
            let storyMD = SwiftyMarkdown(string: deal.story.body)
            storyTextView.dataDetectorTypes = UIDataDetectorTypes.all
            storyTextView.attributedText = storyMD.attributedString()
            storyTextView.sizeToFit()
            storyTextView.layoutIfNeeded()
            
            storyScrollView.scrollsToTop = true
        }
    }
    
    fileprivate func loadBannerView() {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.adUnitID = "ca-app-pub-9026572937829340/4650231965"
        bannerView.rootViewController = self
        bannerView.isAutoloadEnabled = true
    }
}
