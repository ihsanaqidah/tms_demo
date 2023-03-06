import UIKit
import Network

let MESSAGE = """
    {"barcodeId": "\(UUID().uuidString)"}
    """

class ViewController: UIViewController {
    
    lazy var serverListener = ServerListener(delegate: self)
    lazy var clientListener = ClientListener(delegate: self)
    
    var serverUrl: URL?
    var clientLogs: [Any?] = []
    
    @IBOutlet weak var clientBtn: UIButton!
    @IBOutlet weak var serverBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func didTapServer(_ sender: Any) {
        if serverListener.isRunning {
            serverListener.stop()
        } else {
            try? serverListener.start()
        }
        updateServerBtn()
    }
    
    @IBAction func didTapClient(_ sender: Any) {
        if clientListener.isRunning {
            clientListener.stop()
        } else {
            clientListener = ClientListener(delegate: self)
            clientListener.start()
        }
    }
    
    @IBAction func didTapWebview(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webview") as! WebviewController
        
        if let url = serverUrl, var comp = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            comp.path = "/status"
            vc.setDefault(url: comp.url!)
        }
        navigationController?.pushViewController(vc, animated: true)
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
        if serverListener.isRunning {
            return "Server is ON \(serverListener.host):\(serverListener.port)"
        } else {
            return "Server is OFF"
        }
    }
    
    func getClientTitleBtn() -> String {
        if let server = serverUrl {
            return "\(server.host ?? ""):\(server.port ?? 0)"
        } else {
            return "Connect to Server"
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        
        return cell
    }
}

extension ViewController: ConnectionDelegate {
    
    func onIncoming(string: String) {
        showAlert(message: string)
    }
}

extension ViewController: ClientDelegate {
    func onResolveHostServer(url: URL?) {
        print(String(describing: url?.absoluteString))
        serverUrl = url
        updateClientBtn()
    }
}

extension ViewController: ServerListenerDelegate {
    
    func onIncoming(connections: [Connection]) {
        tableView.reloadData()
        updateServerBtn()
    }
}
