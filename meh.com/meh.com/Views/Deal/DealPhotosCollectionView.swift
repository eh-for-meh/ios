//
//  DealPhotosCollectionView.swift
//  meh.com
//
//  Created by Kirin Patel on 5/7/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit

class DealPhotosCollectionView: UICollectionView {
    
    let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    var dealPhotos: Array<UIImage> = [] {
        didSet {
            self.reloadData()
        }
    }
    
    lazy var horizontalInsert = (bounds.width / 1.25) / 8
    
    init() {
        super.init(frame: .zero, collectionViewLayout: layout)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        dataSource = self
        delegate = self
        isPagingEnabled = true
        scrollsToTop = true
        register(DealPhotosCollectionViewCell.self, forCellWithReuseIdentifier: "DealPhotosCollectionViewCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
}

extension DealPhotosCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dealPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DealPhotosCollectionViewCell", for: indexPath) as! DealPhotosCollectionViewCell
        cell.dealPhoto = dealPhotos[indexPath.row]
        return cell
    }
}

extension DealPhotosCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.height
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return horizontalInsert * 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: horizontalInsert, bottom: 0, right: horizontalInsert)
    }
}
