//
//  WebNetService.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/4/23.
//

import Foundation

class WebNetService: NSObject {
    private let workQueue = DispatchQueue.main
    private var netService: NetService?
    
    let name: String
    let port: Int
    let domain: String
    let serviceType: String
    
    deinit {
        netService?.stop()
    }
    
    /// Initializes a new WebNetService instance.
    init(name: String, port: Int = WebNetService.defaultPort, serviceType: String, domain: String) {
        self.name = name
        self.port = port
        self.serviceType = serviceType
        self.domain = domain
    }
    
    /// Starts publishing the service.
    func publish() {
        let serviceName = name
        let servicePort = Int32(port)
        
        workQueue.async {
            self.netService?.stop()
            self.netService = NetService(domain: self.domain, type: self.serviceType, name: serviceName, port: servicePort)
            self.netService!.publish()
        }
    }
    
    /// Stops publishing the service.
    func unpublish() {
        workQueue.async {
            self.netService?.stop()
            self.netService = nil
        }
    }
}

extension WebNetService {
    static let defaultDomain = "local."
    static let defaultServiceType = "_http._tcp"
    static let defaultPort = 8080
}
