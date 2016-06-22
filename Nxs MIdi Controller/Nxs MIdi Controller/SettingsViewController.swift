//
//  SettingsViewController.swift
//  Nxs Midi Controller
//
//  Created by Serge-Olivier Amega on 6/9/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editingChanged(sender: UITextField) {
        guard let text = sender.text else {
            return
        }
        
        guard let app = UIApplication.sharedApplication().delegate as? AppDelegate else {
            return
        }
        
        app.host = text
        
    }

}
