//
//  WheelView.swift
//  Nxs Midi Controller
//
//  Created by Serge-Olivier Amega on 5/28/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

private let indicatorHeight : CGFloat = 80.0

typealias WheelFactor = Float

@IBDesignable
class WheelView: UIView {
    
    var wheelDidChangeCallbacks : [(WheelFactor) -> ()] = []
    
    /**
     * ranges from -1 to 1
     */
    var wheelOffset : CGFloat = 0.0
    var maintainPositionAfterTouch = false
    
    func onWheelChanged(callback: ((WheelFactor) -> ())) {
        wheelDidChangeCallbacks.append(callback)
    }
    
    func wheelDidChange() {
        self.setNeedsDisplay()
        wheelDidChangeCallbacks.forEach {
            $0(Float(wheelOffset))
        }
    }
    
    override func drawRect(rect: CGRect) {
        let y = rect.origin.y + rect.height/2 - indicatorHeight/2 - wheelOffset * rect.height/2
        let r = CGRect(x: rect.origin.x, y: y,
                       width: rect.width, height: indicatorHeight)
        UIColor.blackColor().setFill()
        UIBezierPath(rect: r).fill()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touches.forEach {self.touchAt($0.locationInView(self))}
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touches.forEach {self.touchAt($0.locationInView(self))}
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !maintainPositionAfterTouch {
            wheelOffset = 0.0
            wheelDidChange()
        }
    }
    
    func touchAt(point: CGPoint) {
        wheelOffset = 1 - point.y * 2 / self.frame.height
        wheelDidChange()
    }

}
