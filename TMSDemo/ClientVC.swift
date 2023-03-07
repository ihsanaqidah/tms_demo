//
//  ClientVC.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/7/23.
//

import UIKit
import Telegraph

class ClientVC: UIViewController {
    
    lazy var clientListener = ClientListener(delegate: self)
    private var webSocketClient: WebSocketClient?
    var serverUrl: URL?
    private var serverResponses: [Any] = []
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var connectBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    @IBAction func didTapConnect(_ sender: Any) {
        if clientListener.isRunning {
            clientListener.stop()
            webSocketClient?.disconnect()
        } else {
            clientListener = ClientListener(delegate: self)
            clientListener.start()
        }
    }
    
    func updateClientBtn() {
        let title = getClientTitleBtn()
        connectBtn.setTitle(title, for: .normal)
    }
    
    func getClientTitleBtn() -> String {
        if let _ = serverUrl {
            return "Disconnect to HTTP Server"
        } else {
            return "Connect to HTTP Server"
        }
    }
    
    func connectWebSocketClient() {
        guard let url = serverUrl else { return }
        
        webSocketClient = try! WebSocketClient(url: url)
        webSocketClient?.delegate = self
        webSocketClient?.connect()
    }
}

extension ClientVC: ClientDelegate {
    
    func onResolveHostServer(url: URL?) {
        print(String(describing: url?.absoluteString))
        serverUrl = url
        updateClientBtn()
        
        connectWebSocketClient()
    }
}

extension ClientVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverResponses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell") else {
            return UITableViewCell()
        }
        
        if let label = cell.textLabel {
            
        }
        
        return cell
    }
}

extension ClientVC: WebSocketClientDelegate {
    
    func webSocketClient(_ client: WebSocketClient, didConnectToHost host: String) {
        print("WebSocketClientDelegate didConnectToHost \(host)")
        client.send(text: "\(client.remoteEndpoint?.host ?? "")")
    }
    
    func webSocketClient(_ client: WebSocketClient, didDisconnectWithError error: Error?) {
        // We were disconnected from the server
        print("WebSocketClientDelegate didDisconnectWithError")
    }
    
    func webSocketClient(_ client: WebSocketClient, didReceiveData data: Data) {
        // We received a binary message. Ping, pong and the other opcodes are handled for us.
        print("WebSocketClientDelegate didReceiveData")
    }
    
    func webSocketClient(_ client: WebSocketClient, didReceiveText text: String) {
        // We received a text message, let's send one back
        client.send(text: "WebSocketClientDelegate Message received: \(text)")
        print("didReceiveTextClient \(text)")
    }
}
