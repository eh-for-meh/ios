//
//  MainViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 5/5/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit

@objc class MainViewController: UIViewController {
    
    let collectionView = DealPhotosCollectionView()
    
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
