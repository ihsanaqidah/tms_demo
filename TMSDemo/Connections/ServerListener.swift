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
    private var httpServer = Server()
    private var netService = WebNetService(name: "TMS Demo", serviceType: "_tms._tcp.", domain: "local.")
    
    init(delegate: ServerListenerDelegate?) {
        self.delegate = delegate
        httpServer.delegate = self
        httpServer.route(.GET, "status") { (.ok, "Server is running") }
    }
    
    func start() throws {
        do {
            try httpServer.start()
            netService.publish()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stop() {
        httpServer.stop()
        netService.unpublish()
    }
}

extension ServerListener: ServerDelegate {
    func serverDidStop(_ server: Telegraph.Server, error: Error?) {
        print(server)
    }
}
