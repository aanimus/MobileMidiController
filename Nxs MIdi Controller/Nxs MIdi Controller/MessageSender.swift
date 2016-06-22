//
//  MessageSender.swift
//  Nxs Midi Controller
//
//  Created by Serge-Olivier Amega on 5/25/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class MessageSender: NSObject {
    var udpSocket : AsyncUdpSocket
    var host: String {
        guard let app = UIApplication.sharedApplication().delegate as? AppDelegate else {
            return "192.168.1.20"
        }
        
        return app.host
    }
    
    override init() {
        udpSocket = AsyncUdpSocket()
        super.init()
    }
    
    func sendMessage(msg: Message) {
        let data = NSData(bytes: msg.bytes, length: msg.bytes.count)
        let success = udpSocket.sendData(data, toHost: host, port: 6000, withTimeout: -1, tag: 1)
        print("sending message", success)
    }
}
