//
//  ServerVC.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/7/23.
//

import UIKit
import Telegraph

class ServerVC: UIViewController {
    typealias DateRequest = (timestamp: Date, request: HTTPRequest)
    
    lazy var serverListener = ServerListener()
    private var requests: [DateRequest] = []
    private var connectedPeers: [(endpoint: Endpoint, name: String?)] = [] {
        didSet {
            DispatchQueue.main.async {
                self.connectedPeersBtn.setTitle("Connected Peers \(self.connectedPeers.count)", for: .normal)
            }
        }
    }
    
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var connectedPeersBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
    }
    
    @objc func willResignActive() {
        if serverListener.isRunning {
            didTapConnect(nil)
        }
    }
    
    @IBAction func didTapConnect(_ sender: Any?) {
        if serverListener.isRunning {
            serverListener.stop()
        } else {
            try? serverListener.start(delegate: self)
        }
        updateServerBtn()
    }
    
    func updateServerBtn() {
        let title = getServerTitleBtn()
        connectBtn.setTitle(title, for: .normal)
    }
    
    func getServerTitleBtn() -> String {
        if serverListener.isRunning {
            return "Stop HTTP Server"
        } else {
            return "Start HTTP Server"
        }
    }
}

extension ServerVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell") else {
            return UITableViewCell()
        }
        
        let request = requests[indexPath.row]
        if let label = cell.textLabel {
            label.text = "@\(request.timestamp.asString()) \(request.request.method) \(request.request.uri.path)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = requests[indexPath.row]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TextViewController") as! TextViewController
        vc.title = request.timestamp.asString()
        let bodyString = try? request.request.bodyAsString()
        vc.text = "\(request.request) \n\n BODY: \(bodyString ?? "") \n\n HEADERS: \(request.request.headers)"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ServerVC: ServerListenerDelegate {
    func serverDidStop() {
        connectedPeers = []
    }
    
    func onIncoming(request: HTTPRequest) {
        DispatchQueue.main.async {
            let newRequest = DateRequest(timestamp: Date(), request: request)
            self.requests.insert(newRequest, at: 0)
            self.tableview.performBatchUpdates {
                self.tableview.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
    }
}

extension ServerVC: ServerWebSocketDelegate {
    func server(_ server: Server, webSocketDidConnect webSocket: WebSocket, handshake: HTTPRequest) {
        print("webSocketDidConnect")
        webSocket.send(text: "Welcome!")
    }
    
    func server(_ server: Server, webSocketDidDisconnect webSocket: WebSocket, error: Error?) {
        print("webSocketDidDisconnect")
        
        DispatchQueue.main.async {
            if !self.connectedPeers.isEmpty {
                self.connectedPeers.remove(at: 0)
                self.showAlert(host: self, title: "Peer Disconnected!", message: "[inprogress] to known peer IP/name.")
            }
        }
    }
    
    func server(_ server: Server, webSocket: WebSocket, didReceiveMessage message: WebSocketMessage) {
        switch message.payload {
        case .text(let string):
            print("didReceiveMessage \(string)")
            
        case .binary(let data):
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let name = dict["name"] as? String {
                    DispatchQueue.main.async {
                        if let endpoint = webSocket.remoteEndpoint {
                            self.connectedPeers.append((endpoint: endpoint, name: name))
                            self.showAlert(host: self, title: "Incoming Connection!", message: "name: \(name), IP: \(endpoint.host)")
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        case .none, .close(_, _):
            break
        }
    }
}
