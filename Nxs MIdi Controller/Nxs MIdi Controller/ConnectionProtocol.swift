//
//  ConnectionProtocol.swift
//  Nxs Midi Controller
//
//  Created by Serge-Olivier Amega on 12/14/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import Foundation
import PeerTalk

/*
 usb message type is message type + 100
 */

enum ConnectionProtocol {
    static let port = UInt16(4000)
}

typealias UsbConnectionMessageType = UInt32

extension MessageKind {
    func toUsbType() -> UsbConnectionMessageType {
        return UInt32(self.toByte()) + 100
    }
    
    static func fromUsbType(_ x: UInt32) -> MessageKind? {
        return MessageKind.fromByte(UInt8(x - 100))
    }
}

extension Message {
    init(connectionType type:UInt32, payload:PTData) {
        let data = Data(bytes: payload.data, count: payload.length)
        self.content = [UInt8](data)
        self.kind = MessageKind.fromUsbType(type)!
    }
}
