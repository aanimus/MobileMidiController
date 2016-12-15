//
//  USBConnection.swift
//  Nxs Midi Controller
//
//  Created by Serge-Olivier Amega on 12/14/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import Foundation
import PeerTalk

class UsbConnection: NSObject, Connection {
    
    let mode = ConnectionMode.usb
    
    let queue = DispatchQueue.init(label: "nxs_midi_peerChannelSendFrame",
                                   attributes: DispatchQueue.Attributes(rawValue: 0))
    
    var delegate: ConnectionDelegate?
    var servChannel: PTChannel?
    var peerChannel: PTChannel?
    
    override init() {
        super.init()
        servChannel = PTChannel(delegate: self)
        
        //on start, listen for connections
        servChannel?.listen(onPort: ConnectionProtocol.port, iPv4Address: INADDR_LOOPBACK) { error in
            print("listen on \(INADDR_LOOPBACK) with error \(error)")
        }
    }
    
    deinit {
        servChannel?.close()
        peerChannel?.close()
    }
    
    func send(message: Message) {
        let ptr = UnsafeBufferPointer<UInt8>(start: message.content, count: message.content.count)
        let payload = DispatchData(bytes: ptr) as __DispatchData
        
        let type = message.kind.toUsbType()
        
        //atmoically send message
        queue.sync {
            peerChannel?.sendFrame(ofType: type, tag: PTFrameNoTag, withPayload: payload) {
                err in
                print("sent usb message with \(err)")
            }
        }
    }
}

extension UsbConnection: PTChannelDelegate {
    public func ioFrameChannel(_ channel: PTChannel!, didReceiveFrameOfType type: UInt32, tag: UInt32, payload: PTData!) {
        print("recieved a frame")
    }
    
    func ioFrameChannel(_ channel: PTChannel!, didAcceptConnection otherChannel: PTChannel!, from address: PTAddress!) {
        guard channel != nil else {return}
        self.peerChannel = otherChannel
        
        print("connected!")
    }
}
