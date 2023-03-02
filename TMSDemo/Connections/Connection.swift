//
//  Connection.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/23/23.
//

import Foundation
import Network

class Connection {
    
    private let connection: NWConnection
    var delegate: ConnectionDelegate?
    
    var endpoint: NWEndpoint? {
        connection.endpoint
    }
    
    var service: (name: String, type: String, domain: String, interface: NWInterface?)? {
        if case let NWEndpoint.service(name, type, domain, interface) = connection.endpoint {
            return (name: name, type: type, domain: domain, interface: interface)
        }
        return nil
    }
    
    var serviceName: String? {
        if case let NWEndpoint.service(name, _, _, _) = connection.endpoint {
            return name
        }
        return nil
    }
    
    // outgoing connection
    init(endpoint: NWEndpoint, delegate: ConnectionDelegate?) {
        let params = NWParameters(tls: nil, tcp: .defaultOption)
        params.includePeerToPeer = true
        
        self.delegate = delegate
        self.connection = NWConnection(to: endpoint, using: params)
        start()
    }
    
    // incoming connection
    init(connection: NWConnection, delegate: ConnectionDelegate?) {
        self.delegate = delegate
        self.connection = connection
        start()
    }
    
    func start() {
        connection.stateUpdateHandler = { [weak self] state in
            print("Connection incoming: \(state)")
            
            switch state {
            case .setup:
                break
            case .waiting(_):
                break
            case .preparing:
                break
            case .ready:
                self?.receiveData()
            case .failed(let e):
                print("connection failed: \(e.localizedDescription)")
            case .cancelled:
                break
            @unknown default:
                break
            }
        }
        
        connection.start(queue: .main)
    }
    
    func receiveData() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, _ in
            if let data = data,
               let message = String(data: data, encoding: .utf8) {
                self?.delegate?.onIncoming(string: message)
            }
            self?.receiveData()
        }
    }
    
    func send(string: String) {
        connection.send(content: string.data(using: .utf8), contentContext: .defaultMessage, isComplete: true, completion: .contentProcessed({ error in
            print("Connection.send \(String(describing: error?.localizedDescription))")
        }))
    }
}
