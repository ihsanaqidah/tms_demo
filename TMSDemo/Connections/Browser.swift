//
//  Browser.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/26/23.
//

import Foundation
import Network

class Browser {
    
    private let browser: NWBrowser
    
    init() {
        let params = NWParameters()
        params.includePeerToPeer = true
        
        self.browser = NWBrowser(for: .bonjour(type: "_tms._tcp", domain: nil), using: params)
    }
    
    func start(completion: @escaping (NWBrowser.Result) -> Void) {
        browser.stateUpdateHandler = { state in
            print("Browser.start(completion:) with \(state)")
        }
        
        browser.browseResultsChangedHandler = { results, changes in
            for result in results {
                if case NWEndpoint.service = result.endpoint {
                    completion(result)
                }
            }
        }
        browser.start(queue: .main)
    }
    
    func stop() {
        browser.cancel()
    }
}
