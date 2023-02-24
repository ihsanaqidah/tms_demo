//
//  Extensions.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/24/23.
//

import Foundation
import Network

extension NWProtocolTCP.Options {
    static let defaultOption: NWProtocolTCP.Options = {
        let opt = NWProtocolTCP.Options()
        opt.enableKeepalive = true
        opt.keepaliveIdle = 2
        return opt
    }()
}

extension NWListener {
    static let defaultListener: NWListener? = {
        let listener = try? NWListener(using: NWParameters(tls: nil, tcp: .defaultOption))
        listener?.service = NWListener.Service(type: "TMS Server")
        return listener
    }()
}
