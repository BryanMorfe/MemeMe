//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Bryan Morfe on 1/22/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeTableViewCell"

class MemeTableViewController: UITableViewController {
    
    var memes: [Meme]?
    
    var preferredFontColor: UIColor = .black

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView() // removes empty cells
        tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: 0, right: 0) // Removes the inset set by grouping
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
    
    // MARK: Actions & Selectors
    
    @IBAction func editMeme() {
        tableView.setEditing(true, animated: true)
        tableView.allowsSelectionDuringEditing = true
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditing))
        navigationController?.navigationBar.items?.first?.leftBarButtonItem = button
        set(controllers: [self], toTheme: (UIApplication.shared.delegate as! AppDelegate).appTheme)
    }
    
    func doneEditing() {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMeme))
        navigationController?.navigationBar.items?.first?.leftBarButtonItem = button
        set(controllers: [self], toTheme: (UIApplication.shared.delegate as! AppDelegate).appTheme)
        tableView.setEditing(false, animated: true)
    }

}

// MARK: Helper methods

extension MemeTableViewController {
    
    func loadMemes() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        DispatchQueue.main.async { // Loaded content asynchronously in main queue
            self.tableView.reloadData()
        }
    }
    
    func subscribeToOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadMemes), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    func unsubscribeToOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }
    
}

// MARK: Data Source

extension MemeTableViewController {
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = "\(self.memes![indexPath.row].topText) \(self.memes![indexPath.row].bottomText)"
        cell.textLabel?.textColor = preferredFontColor
        cell.imageView?.image = self.memes![indexPath.row].memedImage
        cell.imageView?.contentMode = .scaleAspectFill
        
        cell.editingAccessoryType = .disclosureIndicator
        
        return cell
    }
    
}

// MARK: Delegate

extension MemeTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            
            let controller = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
            controller.meme = memes![indexPath.row]
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.memes.remove(at: indexPath.row) // Remove the meme being edited
            
            present(controller, animated: true) {
                // a little resetting
                self.tableView.isEditing = false
                let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editMeme))
                self.navigationController?.navigationBar.items?.first?.leftBarButtonItem = button
            }
            
            
        } else {
            
            let controller = MemeDetailViewController()
            controller.setupView(withImage: self.memes![indexPath.row].memedImage)
            self.navigationController!.pushViewController(controller, animated: true)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.view.frame.size.height * 0.125)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            memes?.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
}
