//
//  MessageSender.swift
//  Nxs Midi Controller
//
//  Created by Serge-Olivier Amega on 5/25/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import CocoaAsyncSocket

class MessageSender: NSObject, GCDAsyncSocketDelegate, Connection {
    
    let mode = ConnectionMode.tcp
    
    var delegate: ConnectionDelegate?
    
    var socket = GCDAsyncSocket()
    
    var host: String {
        let app = UIApplication.shared.delegate as! AppDelegate
        return app.settings.host
    }
    
    override init() {
        super.init()
        
        let mainQueue = DispatchQueue.main
        socket = GCDAsyncSocket(delegate: self, delegateQueue: mainQueue)
        updateHost()
    }
    
    func send(message: Message) {
        let data = Data(bytes: UnsafePointer<UInt8>(message.bytes), count: message.bytes.count)
        socket?.write(data, withTimeout: -1, tag: 1)
        print("trying to write")
    }
    
    func socket(_ sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        print("did connect")
    }
    
    func updateHost() {
        do {
            print("trying to connect")
            try socket?.connect(toHost: host, onPort: 6000);
        } catch _ {
            print("error connecting")
        }
    }
}
