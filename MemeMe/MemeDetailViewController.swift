//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Bryan Morfe on 1/23/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    // MARK: Properties
    var imageView: UIImageView?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        set(controllers: [self], toTheme: appDelegate.appTheme)        
    }

    func setupView(withImage image: UIImage) {
        imageView = UIImageView()
        imageView!.frame = CGRect(x: 0, y: 64, width: view.frame.size.width, height: view.frame.size.height - 110)
        imageView!.image = image
        imageView!.contentMode = .scaleAspectFit
        view.addSubview(imageView!)
    }

}
