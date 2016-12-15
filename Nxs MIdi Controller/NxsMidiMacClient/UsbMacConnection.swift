//
//  UsbMacConnection.swift
//  Nxs Midi Controller
//
//  Created by Serge-Olivier Amega on 12/14/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import Foundation
import PeerTalk

enum DeviceChannel {
    case connected(PTChannel), unconnected
}

class UsbMacConnection: NSObject, Connection {
    
    var delegate: ConnectionDelegate?
    var mode = ConnectionMode.usb
    
    //channels connected to devices
    var channels: [NSNumber:DeviceChannel] = [:]
    
    override init() {
        super.init()
        
        listenForDevices()
    }
    
    func listenForDevices() {
        NotificationCenter.default.addObserver(forName: Notification.Name.PTUSBDeviceDidAttach,
                                               object: PTUSBHub.shared(), queue: nil)
        {
            notification in
            
            let deviceId = notification.userInfo!["DeviceID"] as! NSNumber
            print("device did attach id:\(deviceId)")
            
            self.channels[deviceId] = DeviceChannel.unconnected
            self.tryToConnect()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.PTUSBDeviceDidDetach,
                                               object: PTUSBHub.shared(), queue: nil)
        {
            notification in
            
            let deviceId = notification.userInfo!["DeviceID"] as! NSNumber
            print("device did detach id:\(deviceId)")
            
            if let devChannel = self.channels[deviceId] {
                switch devChannel {
                case .connected(let channel):
                    channel.close() //this may not be necessary
                case _: break
                }
            }
            
            self.channels[deviceId] = nil
            
        }
    }
    
    func tryToConnect() {
        
        for (id, dChannel) in channels {
            switch dChannel {
            case .unconnected:
                guard let channel = PTChannel(delegate: self) else {break}
                channel.connect(toPort: Int32(ConnectionProtocol.port),
                                 overUSBHub: PTUSBHub.shared(), deviceID: id)
                {
                    err in
                    print("connect to device?: \(err)")
                }
                self.channels[id] = .connected(channel)
            case _: break
            }
        }
        
    }
    
    func send(message: Message) {
        let ptr = UnsafeBufferPointer<UInt8>(start: message.content, count: message.content.count)
        let payload = DispatchData(bytes: ptr) as __DispatchData
        
        let type = message.kind.toUsbType()
        
        for (_, dChannel) in channels {
            guard case DeviceChannel.connected(let channel) = dChannel else {continue}
            channel.sendFrame(ofType: type, tag: PTFrameNoTag, withPayload: payload) {
                err in
                print("sent usb message with \(err)")
            }
        }
    }
}

extension UsbMacConnection: PTChannelDelegate {
    public func ioFrameChannel(_ channel: PTChannel!,
                               didReceiveFrameOfType type: UInt32,
                               tag: UInt32, payload: PTData!) {
        guard payload != nil else {return}
        
        let message = Message(connectionType: type, payload: payload)
        print("got message \(message)")
        
        self.delegate?.connection(self, didRecieveMessage: message)
    }
}
