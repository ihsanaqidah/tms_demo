//
//  SwifterNetService.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/4/23.
//

import Foundation
import Swifter

class SwifterNetService: NSObject {
    private var netService: NetService?
    private var httpServer = HttpServer()
    
    let name: String
    let port: Int32
    let domain: String = "local"
    let serviceType: String
    
    var isRunning: Bool {
        httpServer.operating
    }
    
    deinit {
        netService?.stop()
    }
    
    /// Initializes a new WebNetService instance.
    init(name: String, port: Int32, serviceType: String) {
        self.name = name
        self.port = port
        self.serviceType = serviceType
        super.init()
        
        httpServer["/status"] = { .ok(.htmlBody("You asked for \($0)"))  }
    }
    
    func start() {
        do {
            try httpServer.start(8080, forceIPv4: true, priority: .userInitiated)
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
