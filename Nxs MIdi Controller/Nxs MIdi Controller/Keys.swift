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

struct Note {
    var kind : NoteKind
    var octave : Int
    
    init(k: NoteKind, o: Int) {
        self.kind = k
        self.octave = o
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