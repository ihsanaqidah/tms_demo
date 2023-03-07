//
//  Protocols.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/26/23.
//

import Foundation
import Telegraph

// MARK: ConnectionDelegate
protocol ConnectionDelegate {
    func onIncoming(string: String)
}
