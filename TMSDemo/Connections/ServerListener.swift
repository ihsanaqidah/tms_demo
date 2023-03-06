//
//  Server.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/23/23.
//

import Foundation
import Telegraph

class ServerListener {
    
    private(set) var delegate: ServerListenerDelegate?
    private let webNetService: TelegraphNetService
    
    var isRunning: Bool {
        webNetService.isRunning
    }
    
    var host: String {
        webNetService.host ?? ""
    }
    
    var port: Int32 {
        webNetService.port
    }
    
    init(delegate: ServerListenerDelegate?) {
        self.delegate = delegate
        self.webNetService = TelegraphNetService(name: "TMS Demo", port: 8080, serviceType: "_tms._tcp")
    }
    
    func start() throws {
        webNetService.start()
    }
    
    func stop() {
        webNetService.stop()
    }
}
