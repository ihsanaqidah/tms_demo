//
//  Extensions.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/24/23.
//

import Foundation
import Network
import Telegraph

extension NWProtocolTCP.Options {
    static let defaultOption: NWProtocolTCP.Options = {
        let opt = NWProtocolTCP.Options()
        opt.enableKeepalive = true
        opt.keepaliveIdle = 2
        return opt
    }()
}

extension Date {
    func asString(_ format: String = "HH:mm:ss:SSSS") -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
}

extension HTTPRequest {
    func bodyAsString() throws -> String {
        let dict = try JSONSerialization.jsonObject(with: self.body, options: []) as? [String: Any] ?? [:]
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        let jsonString: String = String(data: jsonData, encoding: .ascii) ?? ""
        return jsonString
    }
}
