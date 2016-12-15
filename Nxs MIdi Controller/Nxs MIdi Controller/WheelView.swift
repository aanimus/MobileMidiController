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
    
    func onWheelChanged(_ callback: @escaping ((WheelFactor) -> ())) {
        wheelDidChangeCallbacks.append(callback)
    }
    
    func wheelDidChange() {
        self.setNeedsDisplay()
        wheelDidChangeCallbacks.forEach {
            $0(Float(wheelOffset))
        }
    }
    
    override func draw(_ rect: CGRect) {
        let y = rect.origin.y + rect.height/2 - indicatorHeight/2 - wheelOffset * rect.height/2
        let r = CGRect(x: rect.origin.x, y: y,
                       width: rect.width, height: indicatorHeight)
        UIColor.black.setFill()
        UIBezierPath(rect: r).fill()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {self.touchAt($0.location(in: self))}
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {self.touchAt($0.location(in: self))}
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !maintainPositionAfterTouch {
            wheelOffset = 0.0
            wheelDidChange()
        }
    }
    
    func touchAt(_ point: CGPoint) {
        wheelOffset = 1 - point.y * 2 / self.frame.height
        wheelDidChange()
    }

}
