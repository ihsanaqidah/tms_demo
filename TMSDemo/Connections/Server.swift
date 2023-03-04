//
//  Server.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/3/23.
//

import Foundation
import GCDWebServer

protocol ServerDelegate {
    func onIncomingRequest(data: Any?)
}

class Server: NSObject {
    
    private lazy var webServer = GCDWebServer()
    private(set) var isStarted: Bool = false
    var host: String {
        webServer.serverURL?.host ?? ""
    }
    var port: Int {
        webServer.serverURL?.port ?? 0
    }
    var delegate: ServerDelegate?
    
    init(delegate: ServerDelegate?) {
        self.delegate = delegate
    }
    
    func start() {
        webServer.addHandler(forMethod: "GET", path: "/", request: GCDWebServerRequest.self) { req in
            return GCDWebServerDataResponse(html: "<html><body><p>Hello World</p></body></html>")
        }
        webServer.addHandler(forMethod: "GET", path: "/json", request: GCDWebServerRequest.self) { req in
            let jsonData = MESSAGE.data(using: .utf8) ?? Data()
            print(req)
            
            self.delegate?.onIncomingRequest(data: req.query)
            return GCDWebServerDataResponse(data: jsonData, contentType: "application/json")
        }
        webServer.delegate = self
        
        var option: [String: Any] = [:]
        option[GCDWebServerOption_Port] = 8080
        option[GCDWebServerOption_ServerName] = "TMS Demo"
        option[GCDWebServerOption_BonjourType] = "_tms._tcp"
        option[GCDWebServerOption_BonjourName] = "TMS Demo"
        option[GCDWebServerOption_AutomaticallySuspendInBackground] = false
        
        do {
            try webServer.start(options: option)
            print("Visit \(String(describing: webServer.serverURL)) in your web browser")
            isStarted = true
        } catch let error {
            print("FAILED start: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        webServer.stop()
        isStarted = false
    }
}

extension Server: GCDWebServerDelegate {
    func webServerDidCompleteBonjourRegistration(_ server: GCDWebServer) {
        print(server)
    }
    
    func webServerDidConnect(_ server: GCDWebServer) {
        print(server)
    }
    
    func webServerDidStart(_ server: GCDWebServer) {
        print(server)
    }
}
