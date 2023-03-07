//
//  Server.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/23/23.
//

import Foundation
import Telegraph

protocol ServerListenerDelegate: ServerWebSocketDelegate {
    func onIncoming(request: HTTPRequest)
}

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
    
    init() {
        self.webNetService = TelegraphNetService(name: "TMS Demo", port: 8080, serviceType: "_tms._tcp")
    }
    
    func start(delegate: ServerListenerDelegate?) throws {
        webNetService.start(listenerDelegate: delegate)
    }
    
    func stop() {
        webNetService.stop()
    }
}
