//
//  MemeEditonViewController.swift
//  MemeMe
//
//  Created by Bryan Morfe on 1/6/17.
//  Copyright © 2017 Morfe. All rights reserved.
//
//  Note to reviewer: To write some of this code, I had to do some reasearch prior to writing it;
//                    Example: I did not know how to load a single view from a Nib file, but I learned through
//                    research and wrote the code myself. I also didn't know how to check device orientation changes
//                    but I had my suspicions about it being notification based, but again, I did my research prior to doing it.
//                    Everything else is original code and logic. Please let me know of anything you'd do differently and why! Thanks!
//
//                    I added the functionality of the image being cropped to retain only the important material
//                    Also, instead of having a MemeDetailView, I thought It'd be better to allow the selected meme to be edited
//                    So, although it doesn't have a detail view, it does show the meme in the editor and allows you to make changes
//

import UIKit

class MemeEditorViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var libraryButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    // MARK: Other variables
    
    var settingsView: SettingsView!
    var dimmerView: UIView!
    
    var shouldMoveFrame: Bool = false
    
    var memedImage: UIImage!
    var meme: Meme?
    
    var editingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memeEditorViewController = self // Update the reference to this controller
        
        setupSettingsView()
        // Setup text fields with initial font!
        setupTextFields(withFont: appDelegate.preferredFont)
        resetUI()
        
        // If the device has no camera then we don't want to enable it because it would make the app crash
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        set(controllers: [self, appDelegate.activeViewController], toTheme: appDelegate.appTheme) // Set UI to appropiate app theme (this method is in AppTheme.swift)
        
        subscribeToKeyboardNotificationss()
        subscribeToOrientationChangeNotification()
        
        if let meme = self.meme {
            editingMode = true
            memeImageView.image = meme.originalImage
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            setupTextFields(withFont: meme.preferredFont)
            topTextField.isEnabled = true
            bottomTextField.isEnabled = true
            shareButton.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
        unsubscribeToOrientationChangeNotification()
    }
    
    // MARK: Actions

    @IBAction func cameraToggle(_ sender: AnyObject) {
        
        guard !editingMode else {
            let message = "You are in editing mode. To create a new meme finish editing the current one and start a new one."
            let alertController = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Okay", style: .cancel) {
                _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            return
        }
        
        // Fixes a bug that messes up bottom toolbar when in landscape and selecting a photo or taking a new one
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        }
        
        let button = sender as! UIBarButtonItem
        
        let camController = UIImagePickerController()
        camController.delegate = self
        
        switch button.tag {
        case 0:
            camController.sourceType = .camera
            present(camController, animated: true, completion: nil)
        default:
            present(camController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel() {
        if editingMode {
            (UIApplication.shared.delegate as! AppDelegate).memes.append(meme!)
        }
        
        resetUI()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func share() {
        
        let message = "What would you like to do? If you share, your meme will be saved!"
        
        let alertController = UIAlertController(title: "Save & Share", message: message, preferredStyle: .alert)
        
        // Saving just saves it into volatile memory
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            _ in
            self.save()
            self.dismiss(animated: true) {
                self.dismiss(animated: true, completion: nil)
            }
        })
        
        // In this action is where we present the activity the activity view
        let shareAction = UIAlertAction(title: "Share & Save", style: .default, handler: {
            _ in
            self.memedImage = self.generateMemedImage()
            let controller = UIActivityViewController(activityItems: [self.memedImage], applicationActivities: nil)
            
            controller.completionWithItemsHandler = {
                (_, completed, _, error) in
                guard error == nil else {
                    print("An error has occured")
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                if completed {
                    let alertController = UIAlertController(title: "Shared", message: "You have shared your meme!", preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Okay", style: .default) {_ in
                        self.dismiss(animated: true) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    alertController.addAction(okayAction)
                    
                    self.save()
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            self.present(controller, animated: true, completion: nil)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func settings() {
        // Display a custom settings view
        
        // First we check whether the view is hidden or not
        if settingsView.isHidden {
            dimmerView.isHidden = false
            settingsView.isHidden = false
        } else {
            // If it's not hidden, we want to hide it after the animation has finished...
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) {_ in
                self.settingsView.isHidden = true
                self.dimmerView.isHidden = true
            }
        }
        
        // Then we do a nice opacity animation
        let desiredOpacity: Float = settingsView.layer.opacity == 0 ? 1 : 0
        
        UIView.animate(withDuration: 0.3) {
            self.settingsView.layer.opacity = desiredOpacity
            self.dimmerView.layer.opacity = desiredOpacity * 0.4 // Desired opacity but does not allow it to go past 0.4
        }
    }
}

// MARK: Helper methods

extension MemeEditorViewController {

    func setupTextFields(withFont font: UIFont) {
        
        let memeAttributes: [String: Any] = [
            NSFontAttributeName: font,
            NSStrokeWidthAttributeName: -4,
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white
        ]
        
        configure(textField: topTextField, withAttributes: memeAttributes)
        configure(textField: bottomTextField, withAttributes: memeAttributes)
        
    }
    
    func configure(textField: UITextField, withAttributes attributes: [String: Any]) {
        textField.defaultTextAttributes = attributes
        textField.delegate = self
        textField.textAlignment = .center // Because the text fields' width is the same as view, we should center text
    }
    
    func resetUI() {
        
        memeImageView.image = nil // Make sure no image is displayed
        shareButton.isEnabled = false // We wouldn't want to share 'nothing' :}
        topTextField.isEnabled = false // I disable both text fields when no image is present.
        bottomTextField.isEnabled = false // Same as above
        topTextField.text = "TOP TEXT" // Reset both texts to initial state
        bottomTextField.text = "BOTTOM TEXT" // Same as above
        
    }
    
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if shouldMoveFrame {
            view.frame.origin.y = -getKeyboardHeight(notification: notification)
            shouldMoveFrame = false
        }
    }
    
    func keyboardWillHide() {
        
        // If the frame is out of position, return it to the original position.
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
        
    }
    
    func subscribeToKeyboardNotificationss() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func subscribeToOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(calculateSettingsViewsFrames), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    func unsubscribeToOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    func save() {
        
        func printError(errorString: String) {
            print("Unable to print: \(errorString)")
        }
        
        // Although these errors are unlikely to occur, it's better to prevent a crash
        guard let topText = topTextField.text else {
            printError(errorString: "Top text field is empty.")
            return
        }
        
        guard let bottomText = bottomTextField.text else {
            printError(errorString: "Bottom text field is empty.")
            return
        }
        
        guard let originalImage = memeImageView.image else {
            printError(errorString: "There is no image in the view.")
            return
        }
        
        memedImage = generateMemedImage()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        meme = Meme(topText: topText, bottomText: bottomText, originalImage: originalImage, memedImage: memedImage, preferredFont: appDelegate.preferredFont)
        appDelegate.memes.append(meme!)
    }
    
    func determineFrameFor(image: UIImage) -> CGRect {
        // This method returns the actual size of the image *in the container*
        // Are generally bigger than the size of the screen, so they are shrink
        // This 'shrinked' size is what this method gets
        // Additionally, I also need to get the perfect coordinates for the image
        // so that when I crop it, it keeps the entire image
        
        var size: CGSize
        var y = CGFloat()
        var x = CGFloat()
        
        let containerSize = memeImageView.frame.size
        
        let containerWidthToHeightRatio: CGFloat = containerSize.width / containerSize.height
        let imageWidthToHeightRatio: CGFloat = image.size.width / image.size.height
        
        let screenSize = UIScreen.main.bounds.size
        
        if imageWidthToHeightRatio > containerWidthToHeightRatio {
            // If it goes here is because the image width is the same as the container's width
            let newHeight: CGFloat = (containerSize.width / image.size.width) * image.size.height
            size = CGSize(width: containerSize.width, height: newHeight)
            
            // To calculate a new y starting point, I have to know how much height in not occupied by the image
            // Then half of that + what the nav bar has extra should be the starting point
            let emptyHeight = screenSize.height - newHeight
            y = (emptyHeight + 20) / 2
        } else {
            // If it goes here is because the image height is the same as its container's height
            let newWidth: CGFloat = (containerSize.height / image.size.height) * image.size.width
            size = CGSize(width: newWidth, height: containerSize.height)
            
            // Same as above with width
            // Here, the image will always be vertically centered in the container, so it's half
            let emptyWidth = screenSize.width - newWidth
            x = emptyWidth / 2
            y += 64 // Height of nav bar
        }
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    func generateMemedImage() -> UIImage {
        // Hide unnecessesary objects
        navigationBar.isHidden = true
        bottomToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        var memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Addition Step: Cropping the image
        let newFrame = determineFrameFor(image: memeImageView.image!)
        let imageRef = memedImage.cgImage!.cropping(to: newFrame)!
        memedImage = UIImage(cgImage: imageRef)
        
        // Unhide objects
        navigationBar.isHidden = false
        bottomToolbar.isHidden = false
        
        return memedImage
    }
    
    func calculateSettingsViewsFrames() {
        
        let width = view.frame.size.width * 0.80 // 80% of parent view
        let height = view.frame.size.height * 0.4 // 40% of parent view should be enough
        
        let x = view.frame.size.width * 0.1 // I want the view to be in the middle so it should start at half the space it has free in width
        let y = view.frame.size.height * 0.3 // Same as above
        
        settingsView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        dimmerView.frame = CGRect(x: 0, y: 65, width: view.frame.size.width, height: view.frame.size.height - 109)
        // Start after the nav bar (which is 64px tall plus 1px border) and only occupy the picture portion, do not cover toolbar or navbard
        // I subtract 109 because nav bar is 65px + 44px (of the toolbar = 109px
        
    }
    
    func setupSettingsView() {
        settingsView = Bundle.main.loadNibNamed("SettingsView", owner: self, options: nil)?.last as? SettingsView
        
        // I'd also like to add a black opaque view so that the background in a little dimmed when the settings view is shown
        dimmerView = UIView()
        dimmerView.backgroundColor = .black
        
        calculateSettingsViewsFrames() // I made it reusable because when the user changes orientation we have to recalculate
        
        settingsView.configure()
        
        // Add a tap gesture recognizer and dismiss the settings when the dimmer view is tapped
        let tap = UITapGestureRecognizer(target: self, action: #selector(settings))
        dimmerView.addGestureRecognizer(tap)
        
        view.addSubview(dimmerView) // I have to add this one first so that the settings view is on top of this "dimmer view"
        view.addSubview(settingsView)
        
        dimmerView.isHidden = true
        dimmerView.layer.opacity = 0
        
        settingsView.isHidden = true
        settingsView.layer.opacity = 0
    }
    
}

// MARK: TextFields Delegate

extension MemeEditorViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Reset the fields only when they have the initial text
        if textField.text == "TOP TEXT" || textField.text == "BOTTOM TEXT" {
            textField.text = ""
        }
        
        // The "===" is identity and it's used to compare one object to another.
        if textField === bottomTextField {
            shouldMoveFrame = true // I just want to move the frame when editting the bottom field
        }
    }
    
}

// MARK: ImagePickerController Delegate

extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Set the image to the view, dismiss the picker controller, and enable some of the buttons as applicable!
        memeImageView.image = info["UIImagePickerControllerOriginalImage"] as! UIImage?
        dismiss(animated: true, completion: nil)
        shareButton.isEnabled = true
        topTextField.isEnabled = true
        bottomTextField.isEnabled = true
        
    }
    
}
