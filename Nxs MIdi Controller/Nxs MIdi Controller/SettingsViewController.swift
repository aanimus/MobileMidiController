//
//  SettingsViewController.swift
//  Nxs Midi Controller
//
//  Created by Serge-Olivier Amega on 6/9/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

fileprivate let tcpSelectIndex = 0, usbSelectIndex = 1

class SettingsViewController: UIViewController {

    @IBOutlet weak var segmentedYConstraint: NSLayoutConstraint!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var ipAddressField: UITextField!
    @IBOutlet weak var connectionModeControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        if app.settings.connectionMode == .tcp {
            connectionModeControl.selectedSegmentIndex = tcpSelectIndex
        } else {
            connectionModeControl.selectedSegmentIndex = usbSelectIndex
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func changeConnectionModeToTcp() {
        let app = UIApplication.shared.delegate as! AppDelegate
        app.settings.connectionMode = .tcp
        self.ipAddressField.text = app.settings.host
        
        //animate
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            self.segmentedYConstraint.constant = -35
            self.view.layoutIfNeeded()
            
            self.ipAddressLabel.alpha = 1.0
            self.ipAddressField.alpha = 1.0
            self.ipAddressField.isEnabled = true
        }
    }
    
    func changeConnectionModeToUsb() {
        let app = UIApplication.shared.delegate as! AppDelegate
        app.settings.connectionMode = .usb
        
        //animate
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            self.segmentedYConstraint.constant = 0
            self.view.layoutIfNeeded()
            
            self.ipAddressLabel.alpha = 0.0
            self.ipAddressField.alpha = 0.0
            self.ipAddressField.isEnabled = false
        }
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        guard
            let text = sender.text,
            let app = UIApplication.shared.delegate as? AppDelegate
        else {
                return
        }
        
        app.settings.host = text
    }
    
    @IBAction func changeConnectionMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == tcpSelectIndex { ///tcp
            self.changeConnectionModeToTcp()
        } else { //usb
            self.changeConnectionModeToUsb()
        }
    }

}
