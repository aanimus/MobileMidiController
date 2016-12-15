//
//  MessageEncoding.swift
//  Nxs Midi Controller
//
//  Created by Serge-Olivier Amega on 5/24/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import Foundation

func between(_ a:UInt16, _ val:Int16, _ b:UInt16) -> UInt16 {
    let res = max(Int(a), min(Int(val), Int(b)))
    return UInt16(res)
}

/*
 TCP message protocol:
 
 each message is a byte array.
 (zero indexed)
 byte[0]  contains the number of bytes in the message, not counting the first byte.
 byte[1]  contains the message type.
 byte[2:] content
 */

/*
 Content protocol
 
 Message type 0x1:
 3 midi command bytes
 */

enum MessageKind {
    case end, midi
    
    func toByte() -> UInt8 {
        switch self {
        case .end:  return 0
        case .midi: return 1
        }
    }
    
    static func fromByte(_ x:UInt8) -> MessageKind? {
        switch x {
        case 0: return .end
        case 1: return .midi
        case _: return nil
        }
    }
}

struct Message {
    
    var contentAndTypeSize: UInt8 {
        return UInt8(content.count + 1) //potential crash here
    }
    
    var bytes: [UInt8] {
        return [self.contentAndTypeSize, self.kind.toByte()] + self.content
    }
    
    var kind: MessageKind
    var content: [UInt8]
    
    init(content: [UInt8], kind: MessageKind) {
        self.content = content
        self.kind = kind
    }

    init(midiNote note: Note, velocity: UInt8, status: Note.Status) {
        let statusCode : UInt8 = status == .pressed ? 0x90 : 0x80
        self.init(content: [statusCode, note.toMidiNote(), velocity], kind: .midi)
    }
    
    init(midiPitchBendOffset offset : Float, factor : Float) {
        let basePitch : Int16 = 0x2000
        let realPitch : UInt16 = between(0x0000,
                                         basePitch + Int16(factor * offset * Float(0x2000)),
                                         0x4000)
        let firstData : UInt8 = UInt8(realPitch & 0b0000000001111111)
        let secondData : UInt8 = UInt8((realPitch & 0b0011111110000000) >> 7)
        self.init(content: [0xE0, firstData, secondData], kind: .midi)
    }
    
    init(midiModulationOffset offset : Float) {
        let secondData : UInt8 = UInt8(64 + Int8(64 * offset))
        self.init(content: [0xB0, 0x01, secondData], kind: .midi)
    }

}
