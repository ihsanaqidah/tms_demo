//
//  Connection.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/23/23.
//

import Foundation
import Network

protocol ConnectionDelegate: AnyObject {
    
}

class Connection {

    let connection: NWConnection
    weak var delegate: ConnectionDelegate?

    // outgoing connection
    init(endpoint: NWEndpoint) {
        print("PeerConnection outgoing endpoint: \(endpoint)")

        let params = NWParameters(tls: nil, tcp: .defaultOption)
        params.includePeerToPeer = true
        connection = NWConnection(to: endpoint, using: params)
        start()
    }

    // incoming connection
    init(connection: NWConnection) {
        print("PeerConnection incoming connection: \(connection)")
        self.connection = connection
        start()
    }
    
    func start() {
        connection.stateUpdateHandler = { [weak self] state in
            if case .ready = state {
                self?.receiveData()
            }
        }
    }
    
    private func receiveData() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 100) { data, _, _, _ in
            if let data = data,
               let message = String(data: data, encoding: .utf8) {
    
            }
            self.onIncomingData()
        }
    }
}
