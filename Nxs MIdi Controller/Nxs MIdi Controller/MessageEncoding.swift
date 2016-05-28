//
//  MessageEncoding.swift
//  Nxs Midi Controller
//
//  Created by Serge-Olivier Amega on 5/24/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import Foundation

func between(a:UInt16, _ val:Int16, _ b:UInt16) -> UInt16 {
    let res = max(Int(a), min(Int(val), Int(b)))
    return UInt16(res)
}

struct Message {
    
    var bytes: [UInt8]
    
    init() {
        self.bytes = []
    }
    
    init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    static func encodeMidiNotePressed(note: Note, velocity: UInt8) -> Message {
        return Message(bytes: [0xff, 0xff, 0x01, 0x90, note.toMidiNote(), velocity])
    }
    
    static func encodeMidiNoteReleased(note: Note, velocity: UInt8) -> Message {
        return Message(bytes: [0xff, 0xff, 0x01, 0x80, note.toMidiNote(), velocity])
    }
    
    static func encodeMidiPitchBend(offset : WheelFactor, factor : Float) -> Message {
        let basePitch : Int16 = 0x2000
        let realPitch : UInt16 = between(0x0000,
                                         basePitch + Int16(factor * offset * Float(0x2000)),
                                         0x4000)
        let firstData : UInt8 = UInt8(realPitch & 0b0000000001111111)
        let secondData : UInt8 = UInt8((realPitch & 0b0011111110000000) >> 7)
        return Message(bytes: [0xff, 0xff, 0x01, 0xE0, firstData, secondData])
    }
    
    static func encodeMidiModulation(offset : WheelFactor) -> Message {
        let secondData : UInt8 = UInt8(64 + Int8(64 * offset))
        return Message(bytes: [0xff, 0xff, 0x01, 0xB0, 0x01, secondData])
    }

}
