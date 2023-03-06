//
//  Server.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/23/23.
//

import Foundation
import Network
import Telegraph

class ServerListener {
    
    private(set) var delegate: ServerListenerDelegate?
    private let webNetService: WebNetService
    
    init(delegate: ServerListenerDelegate?) {
        self.delegate = delegate
        self.webNetService = WebNetService(name: "TMS Demo", port: 8080, serviceType: "_tms._tcp")
    }
    
    func start() throws {
        webNetService.start()
    }
    
    func stop() {
        webNetService.stop()
    }
}

extension ServerListener: ServerDelegate {
    func serverDidStop(_ server: Telegraph.Server, error: Error?) {
        print(server)
    }
}
