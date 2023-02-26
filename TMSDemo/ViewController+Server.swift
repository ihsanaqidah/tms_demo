//
//  ViewController+Server.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 2/26/23.
//

import Foundation
import Network

extension ViewController: ServerListenerDelegate {
    
    func onIncoming(connections: [Connection]) {
        serverListConnection = connections
        tableView.reloadData()
        updateServerBtn()
    }
}
