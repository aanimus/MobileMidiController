//
//  Keys.swift
//  Nxs MIdi Controller
//
//  Created by Serge-Olivier Amega on 5/24/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import Foundation

/**
 * Enum for musical note kinds. Cs means C sharp
 */
enum NoteKind {
    case C, Cs, D, Ds, E, F, Fs, G, Gs, A, As, B
}

/**
 * converts k to k0 in midi
 */
func noteKindToMidiZero(k: NoteKind) -> UInt8 {
    switch k {
    case .C:
        return 0x18
    case .Cs:
        return 0x19
    case .D:
        return 0x1a
    case .Ds:
        return 0x1b
    case .E:
        return 0x1c
    case .F:
        return 0x1d
    case .Fs:
        return 0x1e
    case .G:
        return 0x1f
    case .Gs:
        return 0x20
    case .A:
        return 0x21
    case .As:
        return 0x22
    case .B:
        return 0x23
    }
}

struct Note {
    var kind : NoteKind
    var octave : Int
    
    init(k: NoteKind, o: Int) {
        self.kind = k
        self.octave = o
    }
    
    func toMidiNote() -> UInt8 {
        return noteKindToMidiZero(self.kind) + UInt8(12 * self.octave)
    }
}

private func arrayOfNotes(noteKinds: [NoteKind], num: Int) -> [Note] {
    var notes : [Note] = []
    for i in 0..<num {
        notes.appendContentsOf(noteKinds.map {Note(k: $0, o: i)})
    }
    return notes
}

func standardNoteArray(numOfOctaves: Int) -> [Note] {
    let noteKindArr : [NoteKind] = [.C, .Cs, .D, .Ds, .E, .F, .Fs, .G, .Gs, .A, .As, .B]
    return arrayOfNotes(noteKindArr, num: numOfOctaves)
}

func nonAccidentalNoteArray(numOfOctaves: Int) -> [Note] {
    let noteKindArr : [NoteKind] = [.C, .D, .E, .F, .G, .A, .B]
    return arrayOfNotes(noteKindArr, num: numOfOctaves)
}
