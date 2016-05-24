//
//  KeyboardView.swift
//  Nxs MIdi Controller
//
//  Created by Serge-Olivier Amega on 5/23/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

// TODO set private

import UIKit

enum KeyOffsetType {
    case OffsetL, OffsetBlack, OffsetMiddle, OffsetFull
}

func offsetAmount(type: KeyOffsetType) -> Float {
    switch type {
    case .OffsetL:
        return 1.0
    case .OffsetBlack:
        return 0.7
    case .OffsetMiddle:
        return 0.8
    case .OffsetFull:
        return (2.0 * offsetAmount(.OffsetL)
            + 2.0 * offsetAmount(.OffsetBlack)
            + offsetAmount(.OffsetMiddle)) / 3.0
    }
}

func generateOffsets(offsets: [KeyOffsetType]) -> [Float] {
    var res : [Float] = []
    for offset in offsets {
        if res.count == 0 {
            res.append(0)
        }
        
        let resLast = res.last!
        let resNew = resLast + offsetAmount(offset)
        res.append(resNew)
    }
    return res
}

let standardKeyboardOffsetTypes : [KeyOffsetType] = [.OffsetL, .OffsetBlack, .OffsetMiddle, .OffsetBlack, .OffsetL,
                                                     .OffsetL, .OffsetBlack, .OffsetMiddle, .OffsetBlack, .OffsetMiddle, .OffsetBlack, .OffsetL]
let standardBottomKeyboardOffsetTypes = [KeyOffsetType](count: 7, repeatedValue: .OffsetFull)

func genScaledOffsets(scale: Float, width: Float, genOffsets: [Float]) -> [Float] {
    let numOfKeyboards : Int = Int(ceil(scale))
    
    var unscaledOffsets = genOffsets
    let unscaledSingleLength : Float = unscaledOffsets.last!
    for _ in 1..<numOfKeyboards {
        var nextOffsets = genOffsets
        nextOffsets.removeFirst()
        let lastOffset = unscaledOffsets.last!
        nextOffsets = nextOffsets.map {$0 + lastOffset}
        unscaledOffsets.appendContentsOf(nextOffsets)
    }
    
    return unscaledOffsets.map {
        $0 / unscaledSingleLength * width / scale
    }
}

func standardTopOffsetsWithScale(scale: Float, width: Float) -> [Float] {
    return genScaledOffsets(scale,
                            width: width,
                            genOffsets: generateOffsets(standardKeyboardOffsetTypes))
}

func standardTopOffsetsWithScaleAndTypes(scale: Float, width: Float) -> ([Float], [KeyOffsetType]) {
    let numOfKeyboards = Int(ceil(scale))
    let scaledOffsets = standardTopOffsetsWithScale(scale, width: width)
    let offsetTypes = arrayRepeat(standardKeyboardOffsetTypes, num: numOfKeyboards)
    return (scaledOffsets, offsetTypes)
}

func standardBottomOffsetsWithScale(scale: Float, width: Float) -> [Float] {
    return genScaledOffsets(scale,
                            width: width,
                            genOffsets: generateOffsets(standardBottomKeyboardOffsetTypes))
}

func indexOfOffset(offset: CGFloat, arr: [CGFloat]) -> Int {
    for i in 0..<arr.count {
        let j = i+1
        if j < arr.count {
            if offset >= arr[i] && offset <= arr[j] {
                return i
            }
        } else {
            return i
        }
    }
    return -1
}

//TODO replace all Int(ceil(horizScale)) with instance variable
class KeyboardView: UIView {
    
    typealias KeyboardCallback = ((Note) -> Void)
    private var onPressCallbacks : [KeyboardCallback] = []
    private var onReleaseCallbacks : [KeyboardCallback] = []
    
    ///how many times a keyboard length (C to B) is visible on screen.
    ///1.0 means a keyboard with keys C to B
    var horizScale : Float = 1.2
    var topKeyScale : CGFloat = 0.6 //must be ∈ [0.0, 1.0]
    var scaledOffsetsTop : [CGFloat] {
        get {
            return standardTopOffsetsWithScale(horizScale, width: Float(self.frame.width)).map {CGFloat($0)}
        }
    }
    var scaledOffsetsBottom : [CGFloat] {
        get {
            return standardBottomOffsetsWithScale(horizScale, width: Float(self.frame.width)).map {CGFloat($0)}
        }
    }
    
    override func drawRect(rect: CGRect) {
        /*
        let path : UIBezierPath = UIBezierPath(roundedRect: CGRect(x:0, y:0, width:20, height: 20) , cornerRadius: 10)
        UIColor.blackColor().setFill()
        path.fill()*/
        multipleTouchEnabled = true// TODO move this to viewcontroller
        drawLowerKeys(rect)
        drawUpperKeys(rect)
    }
    
    func addKeyPressedCallback(callback: KeyboardCallback) {
        onPressCallbacks.append(callback)
    }
    
    func addKeyReleasedCallback(callback: KeyboardCallback) {
        onReleaseCallbacks.append(callback)
    }
    
    private func keyPressed(note: Note) {
        onPressCallbacks.forEach {$0(note)}
        print("key pressed.", note.kind, note.octave)
    }
    
    private func keyReleased(note: Note) {
        onReleaseCallbacks.forEach {$0(note)}
        print("key released.", note.kind, note.octave)
    }
    
    func isInUpperSection(y: CGFloat) -> Bool {
        return y < (topKeyScale * self.frame.height)
    }
    
    func drawLowerKeys(rect: CGRect) {
        UIColor.blackColor().setStroke()
        let keyOffsets : [CGFloat] = scaledOffsetsBottom
        
        for i in 1..<keyOffsets.count {
            let (offsetLeft, offsetRight) = (keyOffsets[i-1], keyOffsets[i])
            let b = UIBezierPath(rect: CGRect(x: offsetLeft, y: 0, width: offsetRight - offsetLeft, height: rect.height))
            b.stroke()
        }
    }
    
    func drawUpperKeys(rect: CGRect) {
        UIColor.blackColor().setFill()
        let (offsets, offsetTypes) = standardTopOffsetsWithScaleAndTypes(horizScale, width: Float(rect.width))
        
        for i in 1..<offsets.count {
            if offsetTypes[i-1] == KeyOffsetType.OffsetBlack {
                let (left, right) = (offsets[i-1], offsets[i])
                let b = UIBezierPath(rect: CGRect(x: CGFloat(left), y: 0.0, width: CGFloat(right - left), height: rect.height * topKeyScale))
                b.fill()
            }
        }
    }

    var activeTouches : [(UITouch,Note)] = []
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touches.forEach {
            let (x,y) = ($0.locationInView(self).x, $0.locationInView(self).y)
            let note = isInUpperSection(y) ? noteForKeyTouchedUpper(x) : noteForKeyTouchedLower(x)
            activeTouches.append(($0, note))
            keyPressed(note)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touches.forEach {touch in
            for i in 0..<activeTouches.count {
                if i < 0 || i >= activeTouches.count {
                    continue
                }
                let (t,n) = activeTouches[i]
                if t == touch {
                    activeTouches.removeAtIndex(i)
                    keyReleased(n)
                }
            }
        }
    }
    
    func noteForKeyTouchedUpper(x: CGFloat) -> Note {
        let i = indexOfOffset(x, arr: scaledOffsetsTop)
        let stdNotes = standardNoteArray(Int(ceil(horizScale)))
        return stdNotes[i]
    }
    
    func noteForKeyTouchedLower(x: CGFloat) -> Note {
        let i = indexOfOffset(x, arr: scaledOffsetsBottom)
        let stdNotes = nonAccidentalNoteArray(Int(ceil(horizScale)))
        return stdNotes[i]
    }

}
