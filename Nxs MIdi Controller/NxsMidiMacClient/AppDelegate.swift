//
//  AppDelegate.swift
//  NxsMidiMacClient
//
//  Created by Serge-Olivier Amega on 12/14/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import Cocoa
import CoreMIDI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ConnectionDelegate {

    var connection = UsbMacConnection()
    var midiEndpoint : MIDIEndpointRef?
    var client = MIDIClientRef()
    var port = MIDIPortRef()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("did finish launching")
        
        var destinations = [MIDIEndpointRef]()
        let numDest = MIDIGetNumberOfDestinations()
        for i in 0..<numDest {
            let dest = MIDIGetDestination(i)
            destinations.append(dest)
            
            let name = getName(object: dest)
            print(name)
        }
        
        midiEndpoint = destinations[0]
        
        MIDIClientCreate(CFString.with(string: "mainClient"), nil, nil, &client)
        
        MIDIOutputPortCreate(client, CFString.with(string: "mainPort"), &port)
        
        connection.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func didConnect(connection: Connection) {
    }
    
    func connection(_ connection: Connection, didRecieveMessage message: Message) {
        guard message.kind == .midi else {return}
        
        var packet = UnsafeMutablePointer<MIDIPacket>.allocate(capacity: 1)
        var packetList = UnsafeMutablePointer<MIDIPacketList>.allocate(capacity: 1)
        packet = MIDIPacketListInit(packetList)
        packet = MIDIPacketListAdd(packetList, 1024, packet, 0, message.content.count, message.content)
        
        MIDISend(port, midiEndpoint!, packetList)
    }

}

func isOffline(object: MIDIObjectRef) -> Bool {
    var result : Int32 = 0
    MIDIObjectGetIntegerProperty(object, kMIDIPropertyOffline, &result)
    return result != 0
}

func getName(object: MIDIObjectRef) -> String? {
    var string : Unmanaged<CFString>? = Unmanaged<CFString>.passRetained("" as CFString)
    MIDIObjectGetStringProperty(object, kMIDIPropertyName, &string)
    let nsstr = string?.takeRetainedValue() as? NSString
    return nsstr as String?
}

extension CFString {
    static func with(string: String) -> CFString {
        let nsstr = string as NSString
        return nsstr as CFString
    }
}
