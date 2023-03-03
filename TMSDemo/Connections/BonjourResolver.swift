//
//  BonjourResolver.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/1/23.
//

import Foundation
import Network

typealias Endpoint = (host: String, port: Int)

final class BonjourResolver: NSObject, NetServiceDelegate {
    
    typealias CompletionHandler = (Result<Endpoint, Error>) -> Void
    
    @discardableResult
    static func resolve(service: NetService, completionHandler: @escaping CompletionHandler) -> BonjourResolver {
        precondition(Thread.isMainThread)
        let resolver = BonjourResolver(service: service, completionHandler: completionHandler)
        resolver.start()
        return resolver
    }
    
    private init(service: NetService, completionHandler: @escaping CompletionHandler) {
        // We want our own copy of the service because we’re going to set a
        // delegate on it but `NetService` does not conform to `NSCopying` so
        // instead we create a copy by copying each property.
        let copy = NetService(domain: service.domain, type: service.type, name: service.name)
        self.service = copy
        self.completionHandler = completionHandler
    }
    
    deinit {
        // If these fire the last reference to us was released while the resolve
        // was still in flight.  That should never happen because we retain
        // ourselves on `start`.
        assert(self.service == nil)
        assert(self.completionHandler == nil)
        assert(self.selfRetain == nil)
    }
    
    private var service: NetService? = nil
    private var completionHandler: (CompletionHandler)? = nil
    private var selfRetain: BonjourResolver? = nil
    
    private func start() {
        precondition(Thread.isMainThread)
        guard let service = self.service else { fatalError() }
        service.delegate = self
        service.resolve(withTimeout: 5.0)
        // Form a temporary retain loop to prevent us from being deinitialised
        // while the resolve is in flight.  We break this loop in `stop(with:)`.
        selfRetain = self
    }
    
    func stop() {
        self.stop(with: .failure(CocoaError(.userCancelled)))
    }
    
    private func stop(with result: Result<(host: String, port: Int), Error>) {
        precondition(Thread.isMainThread)
        self.service?.delegate = nil
        self.service?.stop()
        self.service = nil
        let completionHandler = self.completionHandler
        self.completionHandler = nil
        completionHandler?(result)
        
        selfRetain = nil
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
//        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
//        guard let data = sender.addresses?.first else { return }
//        data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Void in
//                let sockaddrPtr = pointer.bindMemory(to: sockaddr.self)
//                guard let unsafePtr = sockaddrPtr.baseAddress else { return }
//                guard getnameinfo(unsafePtr, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
//                    return
//                }
//            }
//        let ipAddress = String(cString: hostname)
//        print("#resolve endpoint \(ipAddress):\(sender.port)")
//        self.stop(with: .success((ipAddress, sender.port)))
        
        self.stop(with: .success((sender.hostName!, sender.port)))
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
        let code = (errorDict[NetService.errorCode]?.intValue)
            .flatMap { NetService.ErrorCode.init(rawValue: $0) }
            ?? .unknownError
        let error = NSError(domain: NetService.errorDomain, code: code.rawValue, userInfo: nil)
        self.stop(with: .failure(error))
    }
}
