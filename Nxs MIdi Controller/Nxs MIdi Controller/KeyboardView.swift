//
//  KeyboardView.swift
//  Nxs MIdi Controller
//
//  Created by Serge-Olivier Amega on 5/23/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

// TODO set private

import UIKit

private enum KeyOffsetType {
    case offsetL, offsetBlack, offsetMiddle, offsetFull
}

private func offsetAmount(_ type: KeyOffsetType) -> Float {
    switch type {
    case .offsetL:
        return 1.0
    case .offsetBlack:
        return 0.8
    case .offsetMiddle:
        return 0.8
    case .offsetFull:
        return (2.0 * offsetAmount(.offsetL)
            + 2.0 * offsetAmount(.offsetBlack)
            + offsetAmount(.offsetMiddle)) / 3.0
    }
}

private func generateOffsets(_ offsets: [KeyOffsetType]) -> [Float] {
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

private let standardKeyboardOffsetTypes : [KeyOffsetType] = [.offsetL, .offsetBlack, .offsetMiddle, .offsetBlack, .offsetL,
                                                             .offsetL, .offsetBlack, .offsetMiddle, .offsetBlack, .offsetMiddle, .offsetBlack, .offsetL]
private let standardBottomKeyboardOffsetTypes = [KeyOffsetType](repeating: .offsetFull, count: 7)

private func genScaledOffsets(_ scale: Float, width: Float, genOffsets: [Float]) -> [Float] {
    let numOfKeyboards : Int = Int(ceil(scale))
    
    var unscaledOffsets = genOffsets
    let unscaledSingleLength : Float = unscaledOffsets.last!
    for _ in 1..<numOfKeyboards {
        var nextOffsets = genOffsets
        nextOffsets.removeFirst()
        let lastOffset = unscaledOffsets.last!
        nextOffsets = nextOffsets.map {$0 + lastOffset}
        unscaledOffsets.append(contentsOf: nextOffsets)
    }
    
    return unscaledOffsets.map {
        $0 / unscaledSingleLength * width / scale
    }
}

private func standardTopOffsetsWithScale(_ scale: Float, width: Float) -> [Float] {
    return genScaledOffsets(scale,
                            width: width,
                            genOffsets: generateOffsets(standardKeyboardOffsetTypes))
}

private func standardTopOffsetsWithScaleAndTypes(_ scale: Float, width: Float) -> ([Float], [KeyOffsetType]) {
    let numOfKeyboards = Int(ceil(scale))
    let scaledOffsets = standardTopOffsetsWithScale(scale, width: width)
    let offsetTypes = repeatArray(standardKeyboardOffsetTypes, num: numOfKeyboards)
    return (scaledOffsets, offsetTypes)
}

private func standardBottomOffsetsWithScale(_ scale: Float, width: Float) -> [Float] {
    return genScaledOffsets(scale,
                            width: width,
                            genOffsets: generateOffsets(standardBottomKeyboardOffsetTypes))
}

private func indexOfOffset(_ offset: CGFloat, arr: [CGFloat]) -> Int {
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
    fileprivate var onPressCallbacks : [KeyboardCallback] = []
    fileprivate var onReleaseCallbacks : [KeyboardCallback] = []
    
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
    
    lazy var blackKeyBottomImage: UIImage = {
        guard let img = UIImage(named: "blackKey_lower") else {
            print("Error: could not find blackKey_lower image file")
            abort();
        }
        return img
    }()
    
    lazy var blackKeyUpperImage: UIImage = {
        guard let img = UIImage(named: "blackKey_upper") else {
            print("Error: could not find blackKey_upper image file")
            abort();
        }
        return img
    }()
    
    override func draw(_ rect: CGRect) {
        /*
        let path : UIBezierPath = UIBezierPath(roundedRect: CGRect(x:0, y:0, width:20, height: 20) , cornerRadius: 10)
        UIColor.blackColor().setFill()
        path.fill()*/
        isMultipleTouchEnabled = true// TODO move this to viewcontroller
        drawLowerKeys(rect)
        drawUpperKeys(rect)
    }
    
    func addKeyPressedCallback(_ callback: @escaping KeyboardCallback) {
        onPressCallbacks.append(callback)
    }
    
    func addKeyReleasedCallback(_ callback: @escaping KeyboardCallback) {
        onReleaseCallbacks.append(callback)
    }
    
    fileprivate func keyPressed(_ note: Note) {
        onPressCallbacks.forEach {$0(note)}
    }
    
    fileprivate func keyReleased(_ note: Note) {
        onReleaseCallbacks.forEach {$0(note)}
    }
    
    func isInUpperSection(_ y: CGFloat) -> Bool {
        return y < (topKeyScale * self.frame.height)
    }
    
    func drawLowerKeys(_ rect: CGRect) {
        UIColor.black.setStroke()
        let keyOffsets : [CGFloat] = scaledOffsetsBottom
        
        for i in 1..<keyOffsets.count {
            let (offsetLeft, offsetRight) = (keyOffsets[i-1], keyOffsets[i])
            let b = UIBezierPath(rect: CGRect(x: offsetLeft, y: 0, width: offsetRight - offsetLeft, height: rect.height))
            b.stroke()
        }
    }
    
    func drawUpperKeys(_ rect: CGRect) {
        UIColor.black.setFill()
        let (offsets, offsetTypes) = standardTopOffsetsWithScaleAndTypes(horizScale, width: Float(rect.width))
        
        for i in 1..<offsets.count {
            if offsetTypes[i-1] == KeyOffsetType.offsetBlack {
                let (left, right) = (CGFloat(offsets[i-1]), CGFloat(offsets[i]))
                
                let rectWidth = CGFloat(right - left);
                let rectHeight = rectWidth * blackKeyBottomImage.size.height / blackKeyBottomImage.size.width
                let rectY = rect.height * topKeyScale - rectHeight
                
                let bottomRect = CGRect(x: left, y: rectY, width: rectWidth, height: rectHeight)
                blackKeyBottomImage.draw(in: bottomRect)
                
                let topRect = CGRect(x: left, y: 0, width: rectWidth, height: rectY+1)
                blackKeyUpperImage.draw(in: topRect)
            }
        }
    }

    fileprivate var activeTouches : [(UITouch,Note)] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            let (x,y) = ($0.location(in: self).x, $0.location(in: self).y)
            let note = isInUpperSection(y) ? noteForKeyTouchedUpper(x) : noteForKeyTouchedLower(x)
            activeTouches.append(($0, note))
            keyPressed(note)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {touch in
            for i in 0..<activeTouches.count {
                if i < 0 || i >= activeTouches.count {
                    continue
                }
                let (t,n) = activeTouches[i]
                if t == touch {
                    activeTouches.remove(at: i)
                    keyReleased(n)
                }
            }
        }
    }
    
    func noteForKeyTouchedUpper(_ x: CGFloat) -> Note {
        let i = indexOfOffset(x, arr: scaledOffsetsTop)
        let stdNotes = standardNoteArray(Int(ceil(horizScale)))
        return stdNotes[i]
    }
    
    func noteForKeyTouchedLower(_ x: CGFloat) -> Note {
        let i = indexOfOffset(x, arr: scaledOffsetsBottom)
        let stdNotes = nonAccidentalNoteArray(Int(ceil(horizScale)))
        return stdNotes[i]
    }

}
