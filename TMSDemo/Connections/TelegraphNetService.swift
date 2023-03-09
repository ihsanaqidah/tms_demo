//
//  TelegraphNetService.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/4/23.
//

import Foundation
import Telegraph

class TelegraphNetService: NSObject {
    
    private var netService: NetService?
    private var httpServer = Server()
    
    private var listenerDelegate: ServerListenerDelegate?
    
    let name: String
    let port: Int32
    let domain: String = "local"
    let serviceType: String
    
    var isRunning: Bool {
        httpServer.isRunning
    }
    
    var host: String? {
        netService?.hostName
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
        
        self.httpServer.delegate = self
        self.httpServer.route(.GET, "status") { [weak self] request in
            self?.send(request: request)
            return .init(.ok, content: "[custom] Server is running")
        }
        self.httpServer.route(.GET, "uri") { [weak self] request in
            self?.send(request: request)
            var items: [String: String] = [:]
            request.uri.queryItems?.forEach { items[$0.name] = $0.value }
            return .init(.ok, content: "[custom] your request query is \(items)")
        }
        self.httpServer.route(.POST, "headers") { [weak self] request in
            self?.send(request: request)
            return .init(.ok, content: "headers are \(request.headers)")
        }
        self.httpServer.route(.POST, "json", handleBody)
        self.httpServer.route(.GET, "post/:name") { [weak self] request in
            self?.send(request: request)
            let name = request.params["name"]
            return .init(.ok, content: "[custom] your request arg is \(String(describing: name))")
        }
        self.httpServer.route(.GET, "secret/*") { [weak self] request in
            self?.send(request: request)
            return .init(.forbidden)
        }
        self.httpServer.route(.GET, "redirect") { [weak self] request in
            self?.send(request: request)
            let response = HTTPResponse(.temporaryRedirect)
            response.headers.location = "https://www.google.com"
            return response
        }
    }
    
    func start(listenerDelegate: ServerListenerDelegate?) {
        do {
            if isWebsocketEnabled {
                httpServer.webSocketDelegate = listenerDelegate
                httpServer.webSocketConfig.pingInterval = 10
            }
            
            self.listenerDelegate = listenerDelegate
            
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
    
    func handleBody(request: HTTPRequest) -> HTTPResponse {
        send(request: request)
        
        guard !request.body.isEmpty else {
            return .init(.badRequest, content: "Request Body is empty!")
        }
        
        do {
            
            return .init(.ok, content: "[custom] your request body is \(try request.bodyAsString())")
        } catch let error {
            return .init(.init(code: 502, phrase: "Bad Request Body"), content: "[custom] \(error.localizedDescription)")
        }
    }
    
    func send(request: HTTPRequest) {
        listenerDelegate?.onIncoming(request: request)
    }
}

extension TelegraphNetService: ServerDelegate {
    func serverDidStop(_ server: Telegraph.Server, error: Error?) {
        print("serverDidStop error \(String(describing: error))")
        listenerDelegate?.serverDidStop()
    }
}
