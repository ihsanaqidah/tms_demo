//
//  Server.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/23/23.
//

import Foundation
import Network

class ServerListener {
    
    let listener: NWListener
    private(set) var connections: [Connection] = []
    private(set) var delegate: ServerListenerDelegate?
    
    init(delegate: ServerListenerDelegate?) throws {
        let params = NWParameters(tls: nil, tcp: .defaultOption)
        params.includePeerToPeer = true
        
        self.delegate = delegate
        self.listener = try NWListener(using: params)
        self.listener.service = NWListener.Service(name: "TMS Server", type: "_tms._tcp", domain: ".local")
    }
    
    func start() {
        listener.stateUpdateHandler = { [weak self] state in
            print("clientListener?.stateUpdateHandler \(state)")
            
            if case let .failed(error) = state {
                print("Browser failed: \(error.localizedDescription)")
            } else if case .ready = state {
                print("Listener ready on \(String(describing: self?.listener.port))")
            }
        }
        
        listener.newConnectionHandler = { [weak self] connection in
            guard let self = self else { return }
            
            let newConnection = Connection(connection: connection, delegate: self.delegate)
            self.connections.append(newConnection)
            self.delegate?.onIncoming(connections: self.connections)
        }
        
        listener.start(queue: .main)
    }
    
    func stop() {
        listener.cancel()
    }
}
