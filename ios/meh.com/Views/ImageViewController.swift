//
//  ImageViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import Nuke

protocol ImageViewControllerDelegate: class {
    func imageTapped(_ image: UIImage)
    func imageLongPressed(_ image: UIImage)
}

class ImageViewController: UIViewController {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let progressView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView()
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    open var image: URL!
    var delegate: ImageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        downloadImage()
    }
    
    @objc func viewEnlargedImage(_ sender: UITapGestureRecognizer) {
        if let image = imageView.image, let delegate = delegate {
            delegate.imageTapped(image)
        }
    }
    
    @objc func shareImage(_ sender: UILongPressGestureRecognizer) {
        if let image = imageView.image, let delegate = delegate {
            delegate.imageLongPressed(image)
        }
    }
    
    fileprivate func setupView() {
        view.backgroundColor = nil
        view.isUserInteractionEnabled = true
        
        let padding: CGFloat = 20
        
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: padding).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding).isActive = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewEnlargedImage))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(tapGestureRecognizer)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(shareImage))
        imageView.addGestureRecognizer(longPressGesture)
        
        view.addSubview(progressView)
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        progressView.startAnimating()
    }
    
    fileprivate func downloadImage() {
        if !image.absoluteString.contains("https") {
            image = URL(string: image.absoluteString.replacingOccurrences(of: "http", with: "https"))
        }
        
        ImagePipeline.shared.loadImage(
            with: image,
            progress: { response, _, _ in
                self.imageView.image = response?.image
            },
            completion: { response, _ in
                self.progressView.stopAnimating()
                self.imageView.image = response?.image
            }
        )
    }
}
