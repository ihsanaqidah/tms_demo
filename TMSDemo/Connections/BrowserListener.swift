//
//  Browser.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/23/23.
//

import Foundation
import Network

protocol BrowserListenerDelegate: AnyObject {
    func refreshBrowser(with result: Set<NWBrowser.Result>)
}

class BrowserListener {
    
    let browser: NWBrowser
    weak var delegate: BrowserListenerDelegate?
    
    init(delegate: BrowserListenerDelegate) {
        self.delegate = delegate
        
        let params = NWParameters(tls: nil, tcp: .defaultOption)
        browser = NWBrowser(for: .bonjour(type: "_tms._tcp", domain: nil), using: params)
    }
    
    func start() {
        browser.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .failed(let error):
                // Restart the browser if it loses its connection.
                if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_DefunctConnection)) {
                    print("Browser failed with \(error), restarting")
                    self.browser.cancel()
                    self.start()
                } else {
                    print("Browser failed with \(error), stopping")
                    self.browser.cancel()
                }
            case .ready:
                // Post initial results.
                self.delegate?.refreshBrowser(with: self.browser.browseResults)
            case .cancelled:
                self.browser.cancel()
                self.delegate?.refreshBrowser(with: Set())
            default:
                break
            }
        }

        // When the list of discovered endpoints changes, refresh.
        browser.browseResultsChangedHandler = { results, changes in
            self.delegate?.refreshBrowser(with: results)
        }

        // Start browsing and ask for updates on the main queue.
        browser.start(queue: .main)
    }
}
