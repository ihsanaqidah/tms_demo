//
//  WebNetService.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/4/23.
//

import Foundation
import Telegraph

class WebNetService: NSObject {
    private var netService: NetService?
    private var httpServer = Server()
    
    let name: String
    let port: Int32
    let domain: String = "local"
    let serviceType: String
    
    deinit {
        netService?.stop()
    }
    
    /// Initializes a new WebNetService instance.
    init(name: String, port: Int32, serviceType: String) {
        self.name = name
        self.port = port
        self.serviceType = serviceType
        super.init()
        
        self.httpServer.delegate = self
        self.httpServer.route(.GET, "status") { (.ok, "Server is running") }
    }
    
    func start() {
        do {
            try httpServer.start(port: Endpoint.Port(port))
            self.netService = NetService(domain: self.domain, type: self.serviceType, name: name, port: port)
            self.netService!.publish()
        } catch let error {
            print("WebNetService start: \(error)")
        }
    }
    
    func stop() {
        httpServer.stop()
        netService?.stop()
        netService = nil
    }
}

extension WebNetService: ServerDelegate {
    func serverDidStop(_ server: Telegraph.Server, error: Error?) {
        print("serverDidStop server: \(server)")
        print("serverDidStop error \(String(describing: error))")
    }
}
