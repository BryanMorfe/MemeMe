//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Bryan Morfe on 1/22/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeCollectionViewCell"

class MemeCollectionViewController: UICollectionViewController {
    
    var memes: [Meme]?
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let space = CGFloat(3)
        let dimension = (view.frame.size.width - (space * 2)) / 3
        
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        set(controllers: [self], toTheme: appDelegate.appTheme) // Make sure we have the right theme
        appDelegate.activeViewController = self
        
        loadMemes()
        
        subscribeToOrientationChangeNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToOrientationChangeNotification()
    }

}


// MARK: Helper methods

extension MemeCollectionViewController {
    
    func loadMemes() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        DispatchQueue.main.async {
            self.collectionView!.reloadData()
        }
    }
    
    func subscribeToOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadMemes), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    func unsubscribeToOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }
    
}

// MARK: DataSource

extension MemeCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
        
        cell.imageView.clipsToBounds = true // So images won't go outside of cells
        cell.imageView.image = memes![indexPath.row].memedImage
        
        
        return cell
        
    }
    
}

// MARK: Delegate

extension MemeCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let controller = MemeDetailViewController()
        controller.setupView(withImage: self.memes![indexPath.row].memedImage)
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
}
