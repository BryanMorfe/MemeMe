//
//  SettingsView.swift
//  MemeMe
//
//  Created by Bryan Morfe on 1/21/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

class SettingsView: UIView {
    
    // MARK: Outlets
    
    @IBOutlet weak var fontPickerView: UIPickerView!
    @IBOutlet weak var themeSwitch: UISwitch!
    
    // MARK: Other properties
    let fontsAvailable: [String: UIFont] = [
        "Helvetica-Neue": UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        "Impact": UIFont(name: "Impact", size: 40)!,
        "System": UIFont(name: ".SFUIDisplay-Black", size: 38)!
    ]
    
    // MARK: Methods
    
    func getRow(for value: UIFont, in dictionary: [String: UIFont]) -> Int? {
        // This method just finds the appropriate component row for a provided font in a dictionary for String: Font
        var row = Int()
        for (_, val) in dictionary {
            if value === val {
                return row
            }
            row += 1
        }
        return nil
    }
    
    func configure() {
        // It'd be nice to have rounded corners
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        // Set the delegate and data source for the picker view
        fontPickerView.delegate = self
        fontPickerView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Set the starting point of my picker view to the preferred font
        let row = getRow(for: appDelegate.preferredFont, in: fontsAvailable) ?? 0
        fontPickerView.selectRow(row, inComponent: 0, animated: true)
        
        themeSwitch.isOn = appDelegate.appTheme == .dark ? true : false
    }
    
    // MARK: Actions
    
    @IBAction func changeTheme(_ sender: AnyObject) {
        guard let themeSwitch = sender as? UISwitch  else {
            print("Error: Unknown sender received!")
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let memeEditorViewController = appDelegate.memeEditorViewController
        let activeViewController = appDelegate.activeViewController
        
        if themeSwitch.isOn {
            appDelegate.appTheme = .dark
            set(controllers: [memeEditorViewController, activeViewController], toTheme: .dark)
        } else {
            appDelegate.appTheme = .light
            set(controllers: [memeEditorViewController, activeViewController], toTheme: .light)
        }
    }
    
    @IBAction func dismiss() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memeEditorViewController!.settings()
    }
}

// MARK: Picker View Delegate

extension SettingsView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let keyIndex = fontsAvailable.keys.index(fontsAvailable.startIndex, offsetBy: row) // This works just like indexing a string
        let key = fontsAvailable.keys[keyIndex]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memeEditorViewController?.setupTextFields(withFont: fontsAvailable[key]!)
        UserDefaults.standard.set(fontsAvailable[key]!.fontName, forKey: AppDelegate.UserDefaultsKeys.preferredFont)
        appDelegate.preferredFont = UIFont(name: fontsAvailable[key]!.fontName, size: 40)!
    }
    
}

// MARK: Picker View DataSource

extension SettingsView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontsAvailable.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ]
        
        let keyIndex = fontsAvailable.keys.index(fontsAvailable.startIndex, offsetBy: row)
        return NSAttributedString(string: fontsAvailable.keys[keyIndex], attributes: attributes)
    }
    
}
