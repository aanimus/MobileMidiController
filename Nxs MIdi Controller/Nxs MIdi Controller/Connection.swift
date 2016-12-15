//
//  Connection.swift
//  Nxs Midi Controller
//
//  Created by Serge-Olivier Amega on 12/14/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import Foundation


protocol ConnectionDelegate {
    func connection(_ connection: Connection, didRecieveMessage message: Message)
    func didConnect(connection: Connection)
}

protocol Connection {
    var delegate : ConnectionDelegate? {get set}
    var mode : ConnectionMode {get}
    func send(message: Message)
}

enum ConnectionMode {
    case tcp, usb
}
