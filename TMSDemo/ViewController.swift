import UIKit
import Network
import Swifter

let MESSAGE = """
    {"barcodeId": "\(UUID().uuidString)"}
    """
let SERVICE_NAME = "_http._tcp"

class ViewController: UIViewController {
    
    lazy var serverListener = try? ServerListener(delegate: self)
    lazy var clientListener = ClientListener(delegate: self)
    
    var serverListConnection: [Connection] = []
    var clientConnection: Connection?
    
    private var serverEnabled: Bool = false {
        didSet {
            self.updateServerBtn()
        }
    }
    private var clientEnabled: Bool = false {
        didSet {
            self.updateClientBtn()
        }
    }
    
    @IBOutlet var clientBtn: UIButton!
    @IBOutlet var serverBtn: UIButton!
    @IBOutlet var sendHttpServerBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func didTapServer(_ sender: Any) {
        serverEnabled = !serverEnabled
        if serverEnabled {
            serverListener = try? ServerListener(delegate: self)
            serverListener?.start()
        } else {
            serverListener?.stop()
        }
    }
    
    @IBAction func didTapClient(_ sender: Any) {
        clientEnabled = !clientEnabled
        if clientEnabled {
            clientListener = ClientListener(delegate: self)
            clientListener.start()
        } else {
            clientListener.stop()
        }
    }
    
    @IBAction func didTapStopHttpserver(_ sender: UIButton) {
        if let httpServer = serverListener?.httpServer {
            httpServer.stop()
            
            sender.setTitle("Start httServer", for: .normal)
        } else {
            try? serverListener?.httpServer?.start(8080)
            
            sender.setTitle("Stop httServer", for: .normal)
        }
    }
    
    @IBAction func didTapMessageToServer(_ sender: Any) {
        clientConnection?.send(string: MESSAGE)
    }
    
    @IBAction func didTapMessageToClient(_ sender: Any) {
        serverListConnection.forEach {
            $0.send(string: MESSAGE)
        }
    }
    
    @IBAction func messageToHttpserver(_ sender: Any) {
        getHostServer(from: clientConnection) { [weak self] endpoint in
            self?.sendHttpServer(endpoint: endpoint)
        }
    }
    
    @IBAction func didTapOpenWebview(_ sender: Any) {
        getHostServer(from: clientConnection) { [weak self] endpoint in
            guard let endpoint = endpoint else { return }
            
            DispatchQueue.main.async {
                let vc = WebViewController(urlString: "http://\(endpoint.host):\(endpoint.port)/browser")
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func updateServerBtn() {
        let title = getServerTitleBtn()
        serverBtn.setTitle(title, for: .normal)
    }
    
    func updateClientBtn() {
        let title = getClientTitleBtn()
        clientBtn.setTitle(title, for: .normal)
    }
    
    func getServerTitleBtn() -> String {
        let count: Int = serverListConnection.count
        if serverEnabled {
            return "Server is ON [\(count)]"
        } else {
            return "Server is OFF"
        }
    }
    
    func getClientTitleBtn() -> String {
        if clientEnabled, let _ = clientConnection {
            return "Connected!"
        } else {
            return "Connect to Server..."
        }
    }
    
    func showAlert(message: String) {
        let controller = UIAlertController(title: "Incoming message...", message: message, preferredStyle: .alert)
        controller.addAction(
            UIAlertAction(title: "OK", style: .default, handler: { [weak controller] _ in
                controller?.dismiss(animated: true)
            })
        )
        present(controller, animated: true)
    }
    
    func sendHttpServer(endpoint: Endpoint?) {
        guard let endpoint = endpoint,
              let url = URL(string: "http://\(endpoint.host):\(endpoint.port)/barcode") else {
            print("Invalide URL!")
            return
        }
        
        let dict: [String: Any] = ["barcodeId": UUID().uuidString]
        
        var request = URLRequest(url: url)
        request.httpBody = try? JSONSerialization.data(withJSONObject: dict)
        
        print("hit httpServer: \(url.absoluteString)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print(String(describing: response))
            
            if let error = error {
                print("HTTP Request Failed \(error)")
            } else if let data = data, let resString = String(data: data, encoding: .utf8) {
                print(resString)
            }
        }
        task.resume()
    }
    
    func getHostServer(from connection: Connection?, completion: @escaping (Endpoint?) -> Void) {
        if let endpoint = connection?.endpoint,
           case NWEndpoint.service(name: _, type: _, domain: _, interface: _) = endpoint {
            
            let service = NetService(domain: "local.", type: SERVICE_NAME, name: "TMS Server")
            BonjourResolver.resolve(service: service) { result in
                switch result {
                case .success(let host):
                    completion(host)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil)
                }
            }
        } else {
            completion(nil)
            print("No server connected!")
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverListConnection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell") else {
            return UITableViewCell()
        }
        
        
        var service: String?
        if let endpoint = serverListConnection[indexPath.row].endpoint,
           case let NWEndpoint.service(name, _, _, _) = endpoint {
            service = name
            
            cell.textLabel?.text = "\(String(describing: service))"
            cell.detailTextLabel?.text = "\(String(describing: endpoint))"
        } else {
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let connection = serverListConnection[indexPath.row]
        connection.delegate = self
        connection.send(string: MESSAGE)
    }
}

extension ViewController: ConnectionDelegate {
    
    func onIncoming(string: String) {
        showAlert(message: string)
    }
}
