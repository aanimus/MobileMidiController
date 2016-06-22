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
    var messageSender = MessageSender()
    @IBOutlet weak var keyboardViewBottom: KeyboardView!
    @IBOutlet weak var octaveLabel: UILabel!
    @IBOutlet weak var pitchBendView: WheelView!
    @IBOutlet weak var modulationView: WheelView!
    
    func setupKeyboardCallbacks() {
        keyboardViewBottom.addKeyPressedCallback {
            let note = Note(k: $0.kind, o: $0.octave + self.octaveOffset)
            let msg = Message.encodeMidiNotePressed(note, velocity: 90)
            self.messageSender.sendMessage(msg)
        }
        
        keyboardViewBottom.addKeyReleasedCallback {
            let note = Note(k: $0.kind, o: $0.octave + self.octaveOffset)
            let msg = Message.encodeMidiNoteReleased(note, velocity: 90)
            self.messageSender.sendMessage(msg)
        }
    }
    
    func setupWheels() {
        pitchBendView.onWheelChanged {
            let msg = Message.encodeMidiPitchBend($0, factor: 1.0)
            self.messageSender.sendMessage(msg)
            print("pitch")
        }
        
        modulationView.maintainPositionAfterTouch = true
        modulationView.onWheelChanged {
            let msg = Message.encodeMidiModulation($0)
            self.messageSender.sendMessage(msg)
            print("mod")
        }
    }
    
    /**
     * updates only basic ui that doesn't need consistent updating
     */
    func updateUI() {
        octaveLabel.text = String(octaveOffset)
    }
    
    @IBAction func changeOctave(sender: UIButton) {
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
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

