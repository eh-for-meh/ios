//
//  BottomSheetViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 9/23/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import SafariServices
import markymark

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
        segmentControl.insertSegment(withTitle: "Specs", at: 1, animated: true)
        segmentControl.insertSegment(withTitle: "Story", at: 2, animated: true)
        segmentControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return segmentControl
    }()
    
    let featureScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    let featureView: MarkDownTextView = {
        let mv = MarkDownTextView(markDownConfiguration: .view)
        mv.translatesAutoresizingMaskIntoConstraints = false
        mv.backgroundColor = .clear
        return mv
    }()
    
    let specificationScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.backgroundColor = .clear
        scrollView.isHidden = true
        return scrollView
    }()
    
    let specificationView: MarkDownTextView = {
        let mv = MarkDownTextView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        mv.backgroundColor = .clear
        return mv
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
    
    let storyView: MarkDownTextView = {
        let mv = MarkDownTextView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        mv.backgroundColor = .clear
        return mv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        roundCorners()
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
        var offset = featureScrollView.contentOffset.y
        if segmentControl.selectedSegmentIndex == 1 {
            offset = specificationScrollView.contentOffset.y
        } else if segmentControl.selectedSegmentIndex == 2 {
            offset = storyScrollView.contentOffset.y
        }
        
        if (y == yMin && offset == 0 && direction > 0) || (y == yMax) {
            featureScrollView.isScrollEnabled = false
            specificationScrollView.isScrollEnabled = false
            storyScrollView.isScrollEnabled = false
        } else {
            featureScrollView.isScrollEnabled = true
            specificationScrollView.isScrollEnabled = true
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
            self.featureScrollView.isHidden = true;
            self.specificationScrollView.isHidden = false;
            self.storyScrollView.isHidden = true;
            break;
        case 2:
            self.featureScrollView.isHidden = true;
            self.specificationScrollView.isHidden = true;
            self.storyScrollView.isHidden = false;
            break;
        default:
            self.featureScrollView.isHidden = false;
            self.specificationScrollView.isHidden = true;
            self.storyScrollView.isHidden = true;
            break;
        }
    }
    
    @objc func handleBuy() {
        if let url = URL(string: "https://meh.com/#checkout") {
            let view = SFSafariViewController(url: url)
            present(view, animated: true)
        }
    }
    
    fileprivate func animateView() {
        if let deal = deal {
            let textColor: UIColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
            setupDeal()
            if view.backgroundColor == .clear {
                view.backgroundColor = UIColor.color(fromHexString: deal.theme.accentColor)
                pullTab.backgroundColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
                buyButton.backgroundColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
            }
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.25,
                           options: .curveLinear,
                           animations: {
                self.view.frame = CGRect(origin: CGPoint(x: 0, y: self.yMax),
                                         size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
                self.view.backgroundColor = UIColor.color(fromHexString: deal.theme.accentColor)
                self.pullTab.backgroundColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
                self.segmentControl.backgroundColor = deal.theme.foreground == "dark" ? .white : .black
                if #available(iOS 13.0, *) {
                    self.segmentControl.selectedSegmentTintColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
                } else {
                    self.segmentControl.tintColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
                }
                self.segmentControl.selectedSegmentIndex = 0
                self.titleLabel.textColor = textColor
                self.buyButton.backgroundColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
                self.buyButton.tintColor = UIColor.color(fromHexString: deal.theme.accentColor)
                self.buyButton.setTitleColor(UIColor.color(fromHexString: deal.theme.accentColor), for: .normal)
                if deal.soldOut != nil {
                    self.buyButton.alpha = 0
                }
                self.storyTitleLabel.textColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
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
        
        view.addSubview(segmentControl)
        segmentControl.topAnchor.constraint(equalTo: buyButton.bottomAnchor, constant: 20).isActive = true
        segmentControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        segmentControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        segmentControl.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        view.addSubview(featureScrollView)
        featureScrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10).isActive = true
        featureScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150).isActive = true
        featureScrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        featureScrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        featureScrollView.addSubview(featureView)
        featureView.topAnchor.constraint(equalTo: featureScrollView.topAnchor).isActive = true
        featureView.bottomAnchor.constraint(equalTo: featureScrollView.bottomAnchor).isActive = true
        featureView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        featureView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        featureScrollView.bounds = view.bounds
        featureScrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
        
        view.addSubview(specificationScrollView)
        specificationScrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10).isActive = true
        specificationScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150).isActive = true
        specificationScrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        specificationScrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        specificationScrollView.addSubview(specificationView)
        specificationView.topAnchor.constraint(equalTo: specificationScrollView.topAnchor).isActive = true
        specificationView.bottomAnchor.constraint(equalTo: specificationScrollView.bottomAnchor).isActive = true
        specificationView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        specificationView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        specificationScrollView.bounds = view.bounds
        specificationScrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
        
        view.addSubview(storyScrollView)
        storyScrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10).isActive = true
        storyScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150).isActive = true
        storyScrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        storyScrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        storyScrollView.addSubview(storyTitleLabel)
        storyTitleLabel.topAnchor.constraint(equalTo: storyScrollView.topAnchor).isActive = true
        storyTitleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        storyTitleLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        storyScrollView.addSubview(storyView)
        storyView.topAnchor.constraint(equalTo: storyTitleLabel.bottomAnchor, constant: 10).isActive = true
        storyView.bottomAnchor.constraint(equalTo: storyScrollView.bottomAnchor).isActive = true
        storyView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        storyView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        storyScrollView.bounds = view.bounds
        storyScrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
    }
    
    fileprivate func setupDeal() {
        if let deal = deal {
            segmentControl.selectedSegmentIndex = 0
            
            [featureView, specificationView, storyView].forEach {
                $0.styling.headingStyling.fontsForLevels = [.boldSystemFont(ofSize: 25)]
                $0.styling.headingStyling.textColorsForLevels = [UIColor.color(fromHexString: deal.theme.backgroundColor)]
                $0.styling.paragraphStyling.baseFont = .systemFont(ofSize: 20)
                $0.styling.paragraphStyling.textColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
                $0.styling.listStyling.baseFont = .systemFont(ofSize: 20)
                $0.styling.listStyling.bulletFont = .systemFont(ofSize: 20)
                $0.styling.listStyling.bulletColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
                $0.styling.listStyling.textColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
                $0.styling.linkStyling.baseFont = .systemFont(ofSize: 20)
                $0.styling.linkStyling.textColor = UIColor.color(fromHexString: deal.theme.backgroundColor)
            }
            
            featureView.text = deal.features
            featureView.sizeToFit()
            featureView.layoutIfNeeded()
            specificationView.text = deal.specifications
                .replacingOccurrences(of: "\r", with: "\n")
            specificationView.sizeToFit()
            specificationView.layoutIfNeeded()
            
            storyTitleLabel.text = deal.story.title
            
            storyView.text = deal.story.body
            storyView.sizeToFit()
            storyView.layoutIfNeeded()
        }
    }
}
