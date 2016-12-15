//
//  Keys.swift
//  Nxs MIdi Controller
//
//  Created by Serge-Olivier Amega on 5/24/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import Foundation

/**
 * Enum for types of musical notes. Cs means C sharp
 */
enum NoteKind {
    case c, cs, d, ds, e, f, fs, g, gs, a, `as`, b
}

/**
 * converts k to k0 in midi
 */
func noteKindToMidiZero(_ k: NoteKind) -> UInt8 {
    switch k {
    case .c:
        return 0x18
    case .cs:
        return 0x19
    case .d:
        return 0x1a
    case .ds:
        return 0x1b
    case .e:
        return 0x1c
    case .f:
        return 0x1d
    case .fs:
        return 0x1e
    case .g:
        return 0x1f
    case .gs:
        return 0x20
    case .a:
        return 0x21
    case .as:
        return 0x22
    case .b:
        return 0x23
    }
}

struct Note {
    
    enum Status {
        case released, pressed
    }
    
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

private func arrayOfNotes(_ noteKinds: [NoteKind], num: Int) -> [Note] {
    var notes : [Note] = []
    for i in 0..<num {
        notes.append(contentsOf: noteKinds.map {Note(k: $0, o: i)})
    }
    return notes
}

func standardNoteArray(_ numOfOctaves: Int) -> [Note] {
    let noteKindArr : [NoteKind] = [.c, .cs, .d, .ds, .e, .f, .fs, .g, .gs, .a, .as, .b]
    return arrayOfNotes(noteKindArr, num: numOfOctaves)
}

func nonAccidentalNoteArray(_ numOfOctaves: Int) -> [Note] {
    let noteKindArr : [NoteKind] = [.c, .d, .e, .f, .g, .a, .b]
    return arrayOfNotes(noteKindArr, num: numOfOctaves)
}
