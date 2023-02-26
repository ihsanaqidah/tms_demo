//
//  Browser.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/23/23.
//

import Foundation
import Network

class ClientListener {
    
    private let browser = Browser()
    private(set) var connection: Connection?
    var delegate: ClientListenerDelegate?
    
    init(delegate: ClientListenerDelegate?) {
        self.delegate = delegate
    }
    
    func start() {
        browser.start { [weak self] result in
            guard let self = self else { return }
            
            self.connection = Connection(endpoint: result.endpoint, delegate: self.delegate)
            self.delegate?.onIncoming(connection: self.connection)
        }
    }
    
    func stop() {
        browser.stop()
    }
}
