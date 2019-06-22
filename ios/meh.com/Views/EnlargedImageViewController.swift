//
//  EnlargedImageViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 3/1/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit

class EnlargedImageViewController: UIViewController {
    
    let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let effectView: UIVisualEffectView = {
        let vev = UIVisualEffectView()
        vev.translatesAutoresizingMaskIntoConstraints = false
        vev.isUserInteractionEnabled = true
        vev.effect = UIBlurEffect(style: .light)
        return vev
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: .normal)
        return button
    }()
    
    var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    
    var theme: Theme! {
        didSet {
            if theme.dark {
                effectView.effect = UIBlurEffect(style: .dark)
            }
            closeButton.tintColor = theme.accentColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(effectView)
        effectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        effectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        effectView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        effectView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(onPinch))
        effectView.addGestureRecognizer(pinchGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        effectView.addGestureRecognizer(panGesture)
        
        effectView.contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        let longPressGeature = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        imageView.addGestureRecognizer(longPressGeature)
        
        effectView.contentView.addSubview(closeButton)
        closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4).isActive = true
        closeButton.centerXAnchor.constraint(equalTo: effectView.centerXAnchor).isActive = true
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
    }
    
    @objc func onPinch(_ sender: UIPinchGestureRecognizer) {
        imageView.transform = imageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1.0
        if imageOutOfBounds() { dismiss(animated: true) }
    }
    
    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        imageView.center = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: view)
        if imageOutOfBounds() { dismiss(animated: true) }
    }
    
    @objc func onLongPress(_ sender: UILongPressGestureRecognizer) {
        if let image = image {
            let activityViewController = UIActivityViewController(activityItems: [ image ],
                                                                  applicationActivities: nil)
            present(activityViewController, animated: true)
        }
    }
    
    @objc func onClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    fileprivate func imageOutOfBounds() -> Bool {
        return imageView.center.x < 0
            || imageView.center.x > view.bounds.size.width
            || imageView.center.y < 0
            || imageView.center.y > view.bounds.size.height
    }
}
