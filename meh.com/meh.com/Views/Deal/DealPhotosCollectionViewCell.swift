//
//  DealPhotosCollectionViewCell.swift
//  meh.com
//
//  Created by Kirin Patel on 5/7/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit

class DealPhotosCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    var dealPhoto: UIImage? {
        didSet {
            if let image = dealPhoto {
                imageView.image = image
                loadingIndicator.stopAnimating()
            } else {
                loadingIndicator.startAnimating()
                loadingIndicator.isHidden = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        contentView.addSubview(loadingIndicator)
        loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fatalError("awakeFromNib has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        contentView.backgroundColor = .clear
    }
}
