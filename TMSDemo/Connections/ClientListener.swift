//
//  Browser.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/23/23.
//

import Foundation
import Network

class ClientListener {
    
    private let browser: NWBrowser
    private(set) var connection: Connection?
    var delegate: ClientListenerDelegate?
    
    init(delegate: ClientListenerDelegate?) {
        let params = NWParameters()
        params.includePeerToPeer = true
        self.browser = NWBrowser(for: .bonjour(type: SERVICE_NAME, domain: nil), using: params)
        self.delegate = delegate
    }
    
    func start() {
        browser.stateUpdateHandler = { state in
            print("Browser.start(completion:) with \(state)")
        }
        
        browser.browseResultsChangedHandler = { [weak self] results, changes in
            guard let self = self else { return }
            
            for result in results {
                if case NWEndpoint.service(name: _, type: _, domain: _, interface: _) = result.endpoint {
                    print(result.endpoint.debugDescription)

                    self.connection = Connection(endpoint: result.endpoint, delegate: self)
                    self.delegate?.onIncoming(connection: self.connection)
                }
            }
        }
        browser.start(queue: .main)
    }
    
    func stop() {
        browser.cancel()
    }
}

extension ClientListener: ConnectionDelegate {
    func onIncoming(string: String) {
        delegate?.onIncoming(string: string)
    }
}
