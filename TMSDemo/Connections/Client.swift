//
//  Client.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/24/23.
//

import Foundation
import Network

class Client {

    private lazy var browserListener = BrowserListener(delegate: self)

    var connection: Connection?

    func start() {
        browserListener.start()
    }
}

extension Client: BrowserListenerDelegate {
    func refreshBrowser(with result: Set<NWBrowser.Result>) {
        
    }
}
