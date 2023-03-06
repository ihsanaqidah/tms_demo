//
//  Client.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/23/23.
//

import Foundation
import Network

protocol ClientDelegate {
    func onResolveHostServer(url: URL?)
}

class ClientListener: NSObject {
    
    private(set) var delegate: ClientDelegate?
    
    private var browser: NetServiceBrowser?
    private var services: [NetService] = []
    private(set) var serverUrl: URL?
    private(set) var isStarted: Bool = false
    
    init(delegate: ClientDelegate) {
        self.delegate = delegate
    }
    
    func start() {
        browser = NetServiceBrowser()
        browser?.delegate = self
        browser?.searchForServices(ofType: "_tms._tcp", inDomain: "local.")
        isStarted = true
    }
    
    func stop() {
        browser?.stop()
        isStarted = false
    }
    
    func nameForAddress(_ address: Data) -> String {
        var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        let err = address.withUnsafeBytes { buf -> Int32 in
            let sa = buf.baseAddress!.assumingMemoryBound(to: sockaddr.self)
            let saLen = socklen_t(buf.count)
            return getnameinfo(sa, saLen, &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST | NI_NUMERICSERV)
        }
        guard err == 0 else { return "?" }
        return String(cString: host)
    }
    
    private func set(serverUrl: URL?) {
        self.serverUrl = serverUrl
        print("Service URL: \(String(describing: serverUrl?.absoluteString))")

        delegate?.onResolveHostServer(url: serverUrl)
    }
}

extension ClientListener: NetServiceBrowserDelegate {
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("Found service: \(service)")
        if service.name == "TMS Demo", service.type == "_tms._tcp." {
            services.append(service)
            service.delegate = self
            service.resolve(withTimeout: 5)
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("Removed service: \(service)")
        if let index = services.firstIndex(of: service) {
            services.remove(at: index)
        }
    }
}

extension ClientListener: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("Resolved service: \(sender)")
        guard let addresses = sender.addresses else { return }
        
        for address in addresses {
            let ip = nameForAddress(address)
            if let url = URL(string: "http://\(ip):\(sender.port)") {
                set(serverUrl: url)
                break
            }
        }
    }
}
