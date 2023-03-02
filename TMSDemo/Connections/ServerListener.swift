//
//  Server.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/23/23.
//

import Foundation
import Network
import Swifter

class ServerListener {
    
    let listener: NWListener
    var service: NetService?
    var httpServer: HttpServer?
    private(set) var connections: [Connection] = []
    private(set) var delegate: ServerListenerDelegate?
    
    init(delegate: ServerListenerDelegate?) throws {
        let params = NWParameters(tls: nil, tcp: .defaultOption)
        params.includePeerToPeer = true
        
        self.delegate = delegate
        self.listener = try NWListener(using: params)
        self.listener.service = NWListener.Service(name: "TMS Server", type: SERVICE_NAME)
    }
    
    func start() {
        do {
            httpServer?["/barcode"] = { request in
                print(request)
                return HttpResponse.ok(.json("{\"success\": true}"))
//                return HttpResponse.ok(.htmlBody("You resquest \(request)"))
            }
            httpServer?["/browser"] = { request in
                print(request)
                return .ok(.htmlBody("""
                                     <html>
                                     <body>
                                     <h1>Hello Browser.</h1>
                                     <p>You resquest has been loaded!</p>
                                     </body>
                                     </html>
            """))
            }
            try httpServer?.start()
        } catch let e {
            print("something error on httServer")
            print(e.localizedDescription)
        }
        
        listener.stateUpdateHandler = { [weak self] state in
            print("clientListener?.stateUpdateHandler \(state)")
            
            if case let .failed(error) = state {
                print("Browser failed: \(error.localizedDescription)")
            } else if case .ready = state {
                print("Listener ready on \(String(describing: self?.listener.port))")
                
                let port = self?.listener.port?.rawValue ?? 0
                print("Listener started on port \(port)")
                
                // Advertise the service using Bonjour
                self?.service = NetService(domain: "local.", type: SERVICE_NAME, name: "TMS Server", port: Int32(port))
                self?.service?.publish()
            }
        }
        
        listener.newConnectionHandler = { [weak self] connection in
            guard let self = self else { return }
            
            let newConnection = Connection(connection: connection, delegate: self)
            self.connections.append(newConnection)
            self.delegate?.onIncoming(connections: self.connections)
        }
        
        listener.start(queue: .main)
    }
    
    func stop() {
        listener.cancel()
        httpServer?.stop()
        service?.stop()
    }
}

extension ServerListener: ConnectionDelegate {
    func onIncoming(string: String) {
        delegate?.onIncoming(string: string)
    }
}
