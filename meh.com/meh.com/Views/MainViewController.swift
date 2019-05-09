//
//  MainViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 5/5/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import SafariServices

@objc class MainViewController: UIViewController {
    
    let collectionView: DealPhotosCollectionView = {
        let dealPhotosCollectionView = DealPhotosCollectionView()
        dealPhotosCollectionView.alpha = 0
        return dealPhotosCollectionView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.5
        label.alpha = 0
        return label
    }()
    
    let storyWebView: UIWebView = {
        let webView = UIWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scalesPageToFit = true
        webView.backgroundColor = .clear
        webView.alpha = 0
        return webView
    }()
    
    @objc var theme: Theme! {
        didSet {
            if let backgroundColorString = theme.backgroundColor {
                view.backgroundColor = UIColor.color(fromHexString: backgroundColorString)
            }
        }
    }
    
    var deal: Deal? {
        didSet {
            if let deal = deal {
                loadDealPhotos(photoURLs: deal.photos ?? [])
                if let title = deal.title {
                    titleLabel.text = title
                }
                if let story = deal.story,
                    let html = story.asHTML(deal.theme?.backgroundColor ?? "#FFFFFF", deal.theme?.accentColor ?? "#000000") {
                    storyWebView.loadHTMLString(html, baseURL: nil)
                }
                UIView.animate(withDuration: 0.5) {
                    self.collectionView.alpha = 1
                    self.titleLabel.alpha = 1
                }
            }
        }
    }
    var dealPhotos: Array<UIImage?> = [] {
        didSet {
            collectionView.dealPhotos = dealPhotos
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        if deal == nil {
            DealLoader.shared.loadDeal { deal in
                self.deal = deal
            }
        }
    }
    
    fileprivate func setupView() {
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width / 1.25).isActive = true
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        view.addSubview(storyWebView)
        storyWebView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        storyWebView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        storyWebView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        storyWebView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        storyWebView.delegate = self
    }
    
    fileprivate func loadDealPhotos(photoURLs: Array<String>) {
        var urls: Array<URL> = []
        for photoURL in photoURLs {
            let string = photoURL.replacingOccurrences(of: "http://", with: "https://")
            if let url = URL(string: string) {
                urls.append(url)
            }
        }
        dealPhotos = Array<UIImage?>(repeating: nil, count: urls.count)
        for index in 0...(urls.count - 1) {
            let task = URLSession.shared.dataTask(with: urls[index]) { (data, response, error) in
                guard error == nil else { return }
                guard let data = data else { return }
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        self.dealPhotos[index] = image
                    }
                }
            }
            task.resume()
        }
    }
}

extension MainViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        guard let url = request.url, navigationType == .linkClicked else { return true }
        let safariView = SFSafariViewController(url: url)
        present(safariView, animated: true)
        return false
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIView.animate(withDuration: 0.5) {
            webView.alpha = 1
        }
    }
}
