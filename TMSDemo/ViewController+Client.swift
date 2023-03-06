//
//  ViewController+Client.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/26/23.
//

import Foundation
import Network

extension ViewController: ClientDelegate {
    func onResolveHostServer(url: URL?) {
        print(url?.absoluteString)
    }
}
