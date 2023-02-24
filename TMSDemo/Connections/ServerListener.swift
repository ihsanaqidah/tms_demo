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
    
    init() throws {
        // Customize TCP options to enable keepalives.
        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.enableKeepalive = true
        tcpOptions.keepaliveIdle = 2
        
        let params = NWParameters(tls: nil, tcp: tcpOptions)
        params.includePeerToPeer = true
        
        listener = try NWListener(using: params)
        listener.service = NWListener.Service(name: "TMS Server", type: "_tms._tcp")
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
        
        // The system calls this when a new connection arrives at the listener.
        // Start the connection to accept it, cancel to reject it.
        listener.newConnectionHandler = { connection in
            print("clientListener?.newConnectionHandler \(connection)")
        }
        
        listener.start(queue: .main)
    }
    
    func stop() {
        listener.cancel()
    }
}
