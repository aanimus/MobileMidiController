//
//  Utils.swift
//  Nxs MIdi Controller
//
//  Created by Serge-Olivier Amega on 5/24/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import Foundation

func arrayRepeat<T>(arr: [T], num: Int) -> [T] {
    var res : [T] = []
    for _ in 0..<num {
        res.appendContentsOf(arr)
    }
    return res
}