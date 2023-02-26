import UIKit
import Network

let message = """
    {"barcodeId": "\(UUID().uuidString)"}
    """

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
    
    @IBOutlet weak var clientBtn: UIButton!
    @IBOutlet weak var serverBtn: UIButton!
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
    
    @IBAction func didTapMessageToServer(_ sender: Any) {
        clientConnection?.send(string: message)
    }
    
    @IBAction func didTapMessageToClient(_ sender: Any) {
        serverListConnection.forEach {
            $0.send(string: message)
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
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverListConnection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell") else {
            return UITableViewCell()
        }
        
        let endpoint = serverListConnection[indexPath.row].endpoint
        var service: String?
        if case let NWEndpoint.service(name, _, _, _) = endpoint {
            service = name
        }
        
        cell.textLabel?.text = "\(String(describing: service))"
        cell.detailTextLabel?.text = "\(String(describing: endpoint))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let connection = serverListConnection[indexPath.row]
        connection.delegate = self
        connection.send(string: message)
    }
}

extension ViewController: ConnectionDelegate {
    
    func onIncoming(string: String) {
        showAlert(message: message)
    }
}
