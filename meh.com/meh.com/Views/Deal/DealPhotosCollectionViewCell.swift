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
    
    var dealPhoto: UIImage! {
        didSet {
            imageView.image = dealPhoto
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
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
