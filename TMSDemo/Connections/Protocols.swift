//
//  Protocols.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/26/23.
//

import Foundation

// MARK: ConnectionDelegate
protocol ConnectionDelegate {
    func onIncoming(string: String)
}

// MARK: ServerListenerDelegate
protocol ServerListenerDelegate: ConnectionDelegate {
    func onIncoming(connections: [Connection])
}

// MARK: ClientListenerDelegate
protocol ClientListenerDelegate: ConnectionDelegate {
    func onIncoming(connection: Connection?)
}
