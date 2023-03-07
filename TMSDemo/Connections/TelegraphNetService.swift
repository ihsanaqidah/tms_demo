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
        self.httpServer.route(.GET, "status") {
            (.ok, "[custom] Server is running")
        }
        self.httpServer.route(.GET, "uri") { request in
            var items: [String: String] = [:]
            request.uri.queryItems?.forEach { items[$0.name] = $0.value }
            return .init(.ok, content: "[custom] your request query is \(items)")
        }
        self.httpServer.route(.POST, "headers") { request in
            .init(.ok, content: "headers are \(request.headers)")
        }
        self.httpServer.route(.POST, "json", handlePost)
        self.httpServer.route(.GET, "post/:name") { request in
            let name = request.params["name"]
            return .init(.ok, content: "[custom] your request arg is \(String(describing: name))")
        }
        self.httpServer.route(.GET, "secret/*") { .forbidden }
        self.httpServer.route(.GET, "redirect") {
            let response = HTTPResponse(.temporaryRedirect)
            response.headers.location = "https://www.google.com"
            return response
        }
    }
    
    func start(webSocketDelegate: ServerWebSocketDelegate? = nil) {
        do {
            if let delegate = httpServer.webSocketDelegate {
                httpServer.webSocketDelegate = delegate
            }
            
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
    
    func handlePost(request: HTTPRequest) -> HTTPResponse {
        if let dict = try? JSONSerialization.jsonObject(with: request.body, options: []) as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .ascii) {
            
            return .init(.ok, content: "[custom] your request body is \(jsonString)")
        } else {
            return .init(.init(code: 401, phrase: "Bad Request Body"), content: "[custom] your request body is bad")
        }
    }
}

extension TelegraphNetService: ServerDelegate {
    func serverDidStop(_ server: Telegraph.Server, error: Error?) {
        print("serverDidStop server: \(server)")
        print("serverDidStop error \(String(describing: error))")
    }
}
