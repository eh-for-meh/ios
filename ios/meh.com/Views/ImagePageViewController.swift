//
//  ImagePageViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit

protocol ItemPageViewDelegate: class {
    func setCurrentImage(_ index: Int)
}

protocol ImagePageViewControllerDelegate: class {
    func imageTapped(_ image: UIImage)
    func imageLongPressed(_ image: UIImage)
}

class ImagePageViewController: UIPageViewController {
    
    var deal: Deal! {
        didSet {
            setup()
        }
    }
    
    var currentIndex = 0
    var orderedViewControllers = [UIViewController]()
    
    var imagePageViewControllerDelegate: ImagePageViewControllerDelegate?
    var itemViewPageControlDelegate: ItemViewPageControlDelegate? {
        didSet {
            if let delegate = itemViewPageControlDelegate, let deal = deal {
                delegate.itemCountChanged(deal.photos.count)
            }
        }
    }

    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
    }
    
    fileprivate func setup() {
        orderedViewControllers.removeAll()
        
        if let delegate = itemViewPageControlDelegate {
            delegate.itemCountChanged(deal.photos.count)
        }
        
        for photo in deal.photos {
            orderedViewControllers.append(newImageViewController(image: photo))
            
            if let firstViewController = orderedViewControllers.first {
                setViewControllers([firstViewController],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)
            }
        }
    }
    
    fileprivate func newImageViewController(image: URL) -> UIViewController {
        let imageViewController = ImageViewController()
        imageViewController.image = image
        imageViewController.delegate = self
        return imageViewController
    }
}

extension ImagePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        currentIndex = viewControllerIndex
        setPageControlIndex(viewControllerIndex)
        
        if (previousIndex > orderedViewControllers.count) {
            return orderedViewControllers[0]
        } else if (previousIndex < 0) {
            return orderedViewControllers[orderedViewControllers.count - 1]
        } else {
            return orderedViewControllers[previousIndex]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        currentIndex = viewControllerIndex
        setPageControlIndex(viewControllerIndex)
        
        if (nextIndex >= orderedViewControllers.count) {
            return orderedViewControllers[0]
        } else if (nextIndex < 0) {
            return orderedViewControllers[orderedViewControllers.count - 1]
        } else {
            return orderedViewControllers[nextIndex]
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        return firstViewControllerIndex
    }
    
    func setPageControlIndex(_ index: Int) {
        if let delegate = itemViewPageControlDelegate {
            delegate.itemIndexChanged(index)
        }
    }
}

extension ImagePageViewController: ItemPageViewDelegate {
    
    func setCurrentImage(_ index: Int) {
        self.setViewControllers([orderedViewControllers[index]],
                                direction: index > currentIndex ? .forward : .reverse,
                                animated: true,
                                completion: nil)
        currentIndex = index
    }
}


extension ImagePageViewController: ImageViewControllerDelegate {
    
    func imageTapped(_ image: UIImage) {
        if let delegate = imagePageViewControllerDelegate {
            delegate.imageTapped(image)
        }
    }
    
    func imageLongPressed(_ image: UIImage) {
        if let delegate = imagePageViewControllerDelegate {
            delegate.imageLongPressed(image)
        }
    }
}
