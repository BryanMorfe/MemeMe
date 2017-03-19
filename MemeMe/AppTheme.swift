//
//  AppTheme.swift
//  MemeMe
//
//  Created by Bryan Morfe on 1/21/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

enum AppTheme {
    case dark, light
}

private struct Color {
    static let darkGray = UIColor(red: 0.192, green: 0.192, blue: 0.192, alpha: 1)
    static let lightGray = UIColor(red: 0.408, green: 0.408, blue: 0.408, alpha: 1)
    static let defaultBlue = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
}

// MARK: Global Function

func set(controllers: [UIViewController?], toTheme theme: AppTheme) {
    
    switch theme {
    case .dark:
        UIApplication.shared.statusBarStyle = .lightContent // Changes status bar color
        for controller in controllers {
            if let memeEditorViewController = controller as? MemeEditorViewController {
                memeEditorViewController.navigationBar.barStyle = .blackTranslucent
                memeEditorViewController.bottomToolbar.barStyle = .blackTranslucent
                memeEditorViewController.view.backgroundColor = Color.darkGray
            
                if let items = memeEditorViewController.navigationBar.items {
                    for item in items {
                        item.leftBarButtonItem?.tintColor = .orange
                        item.rightBarButtonItem?.tintColor = .orange
                    }
                }
            
                if let items = memeEditorViewController.bottomToolbar.items {
                    for item in items {
                        item.tintColor = .orange
                    }
                }
            } else if let memeTableViewController = controller as? MemeTableViewController {
                set(memeViewController: memeTableViewController, toTheme: theme)
                memeTableViewController.tableView.backgroundColor = Color.darkGray
                memeTableViewController.preferredFontColor = .white
            } else if let memeCollectionViewController = controller as? MemeCollectionViewController {
                set(memeViewController: memeCollectionViewController, toTheme: theme)
                memeCollectionViewController.collectionView?.backgroundColor = Color.darkGray
            } else if let memeDetailViewController = controller as? MemeDetailViewController {
                memeDetailViewController.navigationController?.navigationBar.tintColor = .orange
                memeDetailViewController.view.backgroundColor = Color.darkGray
            }
        }
    case .light:
        UIApplication.shared.statusBarStyle = .default // Changes status bar color
        for controller in controllers {
            if let memeEditorViewController = controller as? MemeEditorViewController {
                memeEditorViewController.navigationBar.barStyle = .default
                memeEditorViewController.bottomToolbar.barStyle = .default
                memeEditorViewController.view.backgroundColor = Color.lightGray
            
                if let items = memeEditorViewController.navigationBar.items {
                    for item in items {
                        item.leftBarButtonItem?.tintColor = Color.defaultBlue // Defaul tint color
                        item.rightBarButtonItem?.tintColor = Color.defaultBlue
                    }
                }
            
                if let items = memeEditorViewController.bottomToolbar.items {
                    for item in items {
                        item.tintColor = Color.defaultBlue
                    }
                }
            }  else if let memeTableViewController = controller as? MemeTableViewController {
                set(memeViewController: memeTableViewController, toTheme: theme)
                memeTableViewController.tableView.backgroundColor = .white
                memeTableViewController.preferredFontColor = .black
            } else if let memeCollectionViewController = controller as? MemeCollectionViewController {
                set(memeViewController: memeCollectionViewController, toTheme: theme)
                memeCollectionViewController.collectionView?.backgroundColor = .white
            } else if let memeDetailViewController = controller as? MemeDetailViewController {
                memeDetailViewController.navigationController?.navigationBar.tintColor = Color.defaultBlue
                memeDetailViewController.view.backgroundColor = .white
            }
        }
    }
    
}

// MARK: Private Functions

private func set(memeViewController: UIViewController, toTheme theme: AppTheme) {
    // The Table and Collection view have so many common properties that it's probably best to reuse the code
    switch(theme) {
    case .dark:
        memeViewController.navigationController?.navigationBar.barStyle = .blackTranslucent
        memeViewController.navigationController?.navigationBar.items?.first?.leftBarButtonItem?.tintColor = .orange
        memeViewController.navigationController?.navigationBar.items?.first?.rightBarButtonItem?.tintColor = .orange
        memeViewController.navigationController?.tabBarController?.tabBar.barStyle = .black
        memeViewController.navigationController?.tabBarController?.tabBar.tintColor = .orange
    case .light:
        memeViewController.navigationController?.navigationBar.barStyle = .default
        memeViewController.navigationController?.navigationBar.items?.first?.leftBarButtonItem?.tintColor = Color.defaultBlue
        memeViewController.navigationController?.navigationBar.items?.first?.rightBarButtonItem?.tintColor = Color.defaultBlue
        memeViewController.navigationController?.tabBarController?.tabBar.barStyle = .default
        memeViewController.navigationController?.tabBarController?.tabBar.tintColor = Color.defaultBlue
    }
}
