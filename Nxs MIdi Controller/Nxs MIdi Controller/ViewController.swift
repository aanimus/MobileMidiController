//
//  ViewController.swift
//  Nxs MIdi Controller
//
//  Created by Serge-Olivier Amega on 5/23/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var octaveOffset : Int = 3
    var messageSender : Connection = UsbConnection()
    @IBOutlet weak var keyboardViewBottom: KeyboardView!
    @IBOutlet weak var octaveLabel: UILabel!
    @IBOutlet weak var pitchBendView: WheelView!
    @IBOutlet weak var modulationView: WheelView!
    
    func setupKeyboardCallbacks() {
        keyboardViewBottom.addKeyPressedCallback {
            let note = Note(k: $0.kind, o: $0.octave + self.octaveOffset)
            let msg = Message(midiNote: note, velocity: 90, status: Note.Status.pressed)
            self.messageSender.send(message: msg)
        }
        
        keyboardViewBottom.addKeyReleasedCallback {
            let note = Note(k: $0.kind, o: $0.octave + self.octaveOffset)
            let msg = Message(midiNote: note, velocity: 90, status: Note.Status.released)
            self.messageSender.send(message: msg)
        }
    }
    
    func setupWheels() {
        pitchBendView.onWheelChanged {
            let msg = Message(midiPitchBendOffset: $0, factor: 1.0)
            self.messageSender.send(message: msg)
            print("pitch")
        }
        
        modulationView.maintainPositionAfterTouch = true
        modulationView.onWheelChanged {
            let msg = Message(midiModulationOffset: $0)
            self.messageSender.send(message: msg)
            print("mod")
        }
    }
    
    /**
     * updates only basic ui that doesn't need consistent updating
     */
    func updateUI() {
        octaveLabel.text = String(octaveOffset)
    }
    
    @IBAction func changeOctave(_ sender: UIButton) {
        guard let title = sender.currentTitle else {
            return
        }
        
        if title == ">" {
            octaveOffset += 1
        } else if title == "<" {
            octaveOffset -= 1;
        }
        
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modulationView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        pitchBendView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        setupKeyboardCallbacks()
        setupWheels()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let mode = app.settings.connectionMode
        
        if mode != self.messageSender.mode {
            if mode == .tcp {
                self.messageSender = MessageSender()
            } else { //usb
                self.messageSender = UsbConnection()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

