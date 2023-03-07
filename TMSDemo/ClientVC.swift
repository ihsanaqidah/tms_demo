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
    private var requests: [URLRequest] = []
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
    }
    
    @objc func willResignActive() {
        if clientListener.isRunning {
            didTapConnect(nil)
        }
    }
    
    func setupRequests() {
        guard let url = serverUrl else { return }
        
        var list: [URLRequest?] = []
        
        var statusReq = makeRequestServer(url: url, path: "/status")
        statusReq?.httpMethod = "GET"
        list.append(statusReq)
        
        var uriReq = makeRequestServer(url: url, path: "/uri", queries: [
            .init(name: "name", value: "tiket-user"),
            .init(name: "address", value: "Bandung"),
            .init(name: "age", value: "20")
        ])
        uriReq?.httpMethod = "GET"
        list.append(uriReq)
        
        var headersReq = makeRequestServer(url: url, path: "/headers")
        headersReq?.httpMethod = "POST"
        headersReq?.setValue(UUID().uuidString, forHTTPHeaderField: "bearer-token")
        list.append(headersReq)
        
        var jsonReq = makeRequestServer(url: url, path: "/json")
        jsonReq?.httpMethod = "POST"
        jsonReq?.httpBody = ("""
        {"title": "example glossary", "number": "2", "boolean": "true"}
        """).data(using: .utf8)
        list.append(jsonReq)
        
        var routePathReq = makeRequestServer(url: url, path: "/post/event")
        routePathReq?.httpMethod = "GET"
        list.append(routePathReq)
        
        var secretReq = makeRequestServer(url: url, path: "/secret")
        secretReq?.httpMethod = "GET"
        list.append(secretReq)
        
        var redirectReq = makeRequestServer(url: url, path: "/redirect")
        redirectReq?.httpMethod = "GET"
        list.append(redirectReq)
        
        requests = list.compactMap { $0 }
    }
    
    func responseHandler(data: Data?, response: URLResponse?, error: Error?) {
        DispatchQueue.main.async {
            self.loadingView.isHidden = true
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TextViewController") as! TextViewController
            var log: String = response.debugDescription
            if let _data = data, let dataString = String(data: _data, encoding: .utf8) {
                log.append("\n\n")
                log.append(dataString)
            }
            if let _error = error {
                log.append("\n\n")
                log.append(_error.localizedDescription)
            }
            vc.text = log
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func didTapConnect(_ sender: Any?) {
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
        if clientListener.isRunning, let _ = serverUrl {
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
    
    func makeRequestServer(url: URL, path: String, queries: [URLQueryItem] = []) -> URLRequest? {
        guard var comp = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { return nil }
        
        comp.path = path
        comp.queryItems = queries
        
        guard let url = comp.url
        else { return nil }
        
        return URLRequest(url: url)
    }
}

extension ClientVC: ClientDelegate {
    
    func onResolveHostServer(url: URL?) {
        print(String(describing: url?.absoluteString))
        serverUrl = url
        updateClientBtn()
        
        connectWebSocketClient()
        
        setupRequests()
        tableview.reloadData()
    }
}

extension ClientVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell") else {
            return UITableViewCell()
        }
        
        let request = requests[indexPath.row]
        if let label = cell.textLabel {
            label.text = request.url?.absoluteString
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = requests[indexPath.row]
        let task = URLSession.shared.dataTask(with: request, completionHandler: responseHandler)
        task.resume()
        loadingView.isHidden = false
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
        
        DispatchQueue.main.async {
            self.requests = []
            self.tableview.reloadData()
            
            self.updateClientBtn()
            self.showAlert(host: self, title: "Server Disconnected!", message: error?.localizedDescription ?? "")
        }
    }
    
    func webSocketClient(_ client: WebSocketClient, didReceiveData data: Data) {
        // We received a binary message. Ping, pong and the other opcodes are handled for us.
        print("WebSocketClientDelegate didReceiveData")
    }
    
    func webSocketClient(_ client: WebSocketClient, didReceiveText text: String) {
        if text == "Welcome!", let dataJson = "{\"name\": \"\(UIDevice.current.name)\"}".data(using: .utf8) {
            client.send(data: dataJson)
        }
    }
}
