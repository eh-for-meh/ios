//
//  ItemViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import WebKit

protocol ItemViewPageControlDelegate: class {
    func itemCountChanged(_ count: Int)
    func itemIndexChanged(_ index: Int)
}

class DealViewController: UIViewController {
    
    let imagePageViewController = ImagePageViewController()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.hidesForSinglePage = true
        pageControl.addTarget(self, action: #selector(handlePageChange), for: .touchUpInside)
        return pageControl
    }()
    
    let itemView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 36, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    let mehButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitle("meh", for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .clear
        button.setTitleColor(.clear, for: .normal)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(handleMeh), for: .touchUpInside)
        return button
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 30
        return label
    }()
    
    let webView: WKWebView = {
        let wb = WKWebView()
        wb.translatesAutoresizingMaskIntoConstraints = false
        return wb
    }()
    
    let webViewViewController: UIViewController = {
        let viewController = UIViewController()
        return viewController
    }()
    
    var deal: Deal! {
        didSet {
            setupDeal()
            imagePageViewController.deal = deal
            imagePageViewController.imagePageViewControllerDelegate = self
        }
    }
    
    var itemPageViewDelegate: ItemPageViewDelegate!
    var forumPostURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        webView.navigationDelegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if deal != nil {
            return deal.theme.foreground == "dark" ? .lightContent : .default
        }
        
        return .default
    }
    
    @objc func handleMeh() {
        rotateMehButton()
        guard let url = URL(string: "https://meh.com") else { return }
        webView.load(URLRequest(url: url))
    }
    
    @objc func handlePageChange() {
        itemPageViewDelegate.setCurrentImage(pageControl.currentPage)
    }

    private func setupView() {
        view.backgroundColor = .clear
        
        let padding: CGFloat = 20
        
        view.addSubview(itemView)
        itemView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        itemView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        itemView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        itemView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        imagePageViewController.itemViewPageControlDelegate = self
        itemPageViewDelegate = imagePageViewController.self
        itemView.addSubview(imagePageViewController.view)
        imagePageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        imagePageViewController.view.topAnchor.constraint(equalTo: itemView.topAnchor).isActive = true
        imagePageViewController.view.leftAnchor.constraint(equalTo: itemView.leftAnchor).isActive = true
        imagePageViewController.view.rightAnchor.constraint(equalTo: itemView.rightAnchor).isActive = true
        
        itemView.addSubview(pageControl)
        pageControl.topAnchor.constraint(equalTo: imagePageViewController.view.bottomAnchor, constant: 10).isActive = true
        pageControl.leftAnchor.constraint(equalTo: itemView.leftAnchor).isActive = true
        pageControl.rightAnchor.constraint(equalTo: itemView.rightAnchor).isActive = true
        
        itemView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: padding).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: -padding).isActive = true
        
        let buttonView = UIView()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.backgroundColor = .clear
        itemView.addSubview(buttonView)
        buttonView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        buttonView.bottomAnchor.constraint(equalTo: itemView.bottomAnchor).isActive = true
        buttonView.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: padding).isActive = true
        buttonView.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: -padding).isActive = true
        buttonView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        buttonView.addSubview(priceLabel)
        priceLabel.topAnchor.constraint(equalTo: buttonView.topAnchor).isActive = true
        priceLabel.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true
        priceLabel.leftAnchor.constraint(equalTo: buttonView.leftAnchor).isActive = true
        
        buttonView.addSubview(mehButton)
        mehButton.topAnchor.constraint(equalTo: buttonView.topAnchor).isActive = true
        mehButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true
        mehButton.rightAnchor.constraint(equalTo: buttonView.rightAnchor).isActive = true
        mehButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        webViewViewController.view.backgroundColor = .white
        webViewViewController.view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: webViewViewController.view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewViewController.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: webViewViewController.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: webViewViewController.view.safeAreaLayoutGuide.rightAnchor).isActive = true
    }
    
    fileprivate func setupDeal() {
        titleLabel.text = deal.title
        titleLabel.setNeedsLayout()
        titleLabel.setNeedsDisplay()
        
        // Checks to see if deal is sold out. If it is AND it is the current
        // deal, then the price will be shown as "SOLD OUT".
        if deal.soldOut != nil {
            priceLabel.text = "SOLD OUT"
        } else {
            priceLabel.text = calculatePrices(deal.items)
        }
        
        if let topic = deal.topic {
            forumPostURL = topic.url
        }
        
        animateUI(theme: deal.theme)
    }
    
    fileprivate func animateUI(theme: Theme) {
        let mehPressedFor = UserDefaults.standard.string(forKey: "meh")
        UIView.animate(withDuration: 0.5, animations: {
            self.itemView.alpha = 1
            self.pageControl.pageIndicatorTintColor = UIColor.color(fromHexString: theme.accentColor)
            self.mehButton.backgroundColor = UIColor.color(fromHexString: theme.accentColor)
            self.mehButton.tintColor = UIColor.color(fromHexString: theme.backgroundColor)
            self.mehButton.setTitleColor(UIColor.color(fromHexString: theme.backgroundColor), for: .normal)
            self.mehButton.isHidden = mehPressedFor == self.deal.id
            if self.deal.date != nil {
                self.mehButton.isHidden = true
            }
            self.priceLabel.textColor = UIColor.color(fromHexString: theme.accentColor)
            self.pageControl.currentPageIndicatorTintColor = theme.foreground == "dark" ? .white : .black
            self.titleLabel.textColor = UIColor.color(fromHexString: theme.accentColor)
        })
    }
    
    fileprivate func calculatePrices(_ items: [Item]) -> String {
        var min: CGFloat = .infinity
        var max: CGFloat = 0
        
        for item in items {
            if item.price < min {
                min = item.price
                if max == 0 {
                    max = item.price
                }
            } else if item.price > max {
                max = item.price
            }
        }
        
        var sMin: Any = min
        var sMax: Any = max
        
        if min.truncatingRemainder(dividingBy: 1.0) == 0 {
            sMin = String(format: "%g", min)
        }
        
        if max.truncatingRemainder(dividingBy: 1.0) == 0 {
            sMax = String(format: "%g", max)
        }
        
        if items.count == 1 || min == max {
            return "$\(sMin)"
        } else {
            return "$\(sMin) - $\(sMax)"
        }
    }
    
    fileprivate func rotateMehButton() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = CGFloat.pi * 2
        rotateAnimation.duration = 0.75
        rotateAnimation.repeatCount = Float.infinity
        
        mehButton.isEnabled = false
        mehButton.layer.add(rotateAnimation, forKey: nil)
    }
    
    fileprivate func resetMehButton() {
        mehButton.isEnabled = true
        mehButton.layer.removeAllAnimations()
    }
}

extension DealViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        guard let host = url.host, host == "meh.com" else { return }
        switch url.path {
        case "/":
            webView.evaluateJavaScript("document.querySelectorAll('form')[1].submit();") { (a, err) in
                guard err == nil else {
                    let alert = UIAlertController(title: "Unable to press the meh button",
                                                  message: "An unexpected error happened when trying to press the meh button, please try again later.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true) {
                        self.resetMehButton()
                    }
                    return
                }
            }
            break
        case "/account/signin":
            let alert = UIAlertController(title: "Sign in required", message: "You must be signed in to meh.com in order to rate this deal.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.present(self.webViewViewController, animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)

            self.present(alert, animated: true) {
                self.resetMehButton()
            }
            break
        case deal.url.path.replacingOccurrences(of: "/deals", with: "/vote"):
            fallthrough
        case deal.url.path:
            self.mehButton.isHidden = true
            if self.webViewViewController.isBeingPresented {
                self.dismiss(animated: true)
            }
            UserDefaults.standard.set(deal.id, forKey: "meh")
            if !UserDefaults.standard.bool(forKey: "mehDisclaimer") {
                let alert = UIAlertController(title: "The meh button",
                                             message: "The meh button now remembers if you have pressed it for the currently active deal. If you have, it will not appear until there is a new deal.",
                                             preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                   UserDefaults.standard.set(true, forKey: "mehDisclaimer")
                }))
                present(alert, animated: true) {
                    self.resetMehButton()
                }
            }
        default:
            break
        }
    }
}

extension DealViewController: ItemViewPageControlDelegate {
    
    func itemCountChanged(_ count: Int) {
        pageControl.numberOfPages = count
    }
    
    func itemIndexChanged(_ index: Int) {
        pageControl.currentPage = index
    }
}

extension DealViewController: ImagePageViewControllerDelegate {
    
    func imageTapped(_ image: UIImage) {
        let view = EnlargedImageViewController()
        view.image = image
        view.theme = deal.theme
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        present(view, animated: true)
    }
    
    func imageLongPressed(_ image: UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [ image ], applicationActivities: nil)
        activityViewController.title = "Share image"
        activityViewController.excludedActivityTypes = []
        activityViewController.popoverPresentationController?.sourceView = view
        activityViewController.popoverPresentationController?.sourceRect = imagePageViewController.view.frame
        present(activityViewController, animated: true)
    }
}
