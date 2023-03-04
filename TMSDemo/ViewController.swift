import UIKit
import Network
import GCDWebServer

let MESSAGE = """
    {"barcodeId": "\(UUID().uuidString)"}
    """

class ViewController: UIViewController {
    
    lazy var webServer = Server(delegate: self)
    lazy var clientListener = Client(delegate: self)
    var hostServer: URL?
    var logs: [Any?] = []
    
    @IBOutlet weak var clientBtn: UIButton!
    @IBOutlet weak var serverBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func didTapServer(_ sender: Any) {
        if webServer.isStarted {
            webServer.stop()
        } else {
            webServer.start()
        }
        updateServerBtn()
    }
    
    @IBAction func didTapClient(_ sender: Any) {
        if clientListener.isStarted {
            clientListener.stop()
        } else {
            clientListener = Client(delegate: self)
            clientListener.start()
        }
    }
    
    @IBAction func didTapMessageToServer(_ sender: Any) {
        guard var url = hostServer else { return }
        url = url.appendingPathComponent("/json?message=client-is-here")
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, url, error in
            if let data = data {
                let string = String(data: data, encoding: .utf8)
                print("response: \(string)")
            } else if let e = error {
                print(e.localizedDescription)
            }
        }
        task.resume()
    }
    
    @IBAction func didTapMessageToClient(_ sender: Any) {
        
    }
    
    @IBAction func didTapOpenWebview(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webview") as! WebviewController
        
        vc.set(url: hostServer)
        self.navigationController?.pushViewController(vc, animated: true)
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
        if webServer.isStarted {
            return "Server is ON \(webServer.host):\(webServer.port)"
        } else {
            return "Server is OFF"
        }
    }
    
    func getClientTitleBtn() -> String {
        if let server = hostServer {
            return "\(server.host ?? ""):\(server.port ?? 0)"
        } else {
            return "Connect Server IP"
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
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = String(describing: logs[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ViewController: ClientDelegate {
    
    func onResolveHostServer(url: URL?) {
        hostServer = url
        updateClientBtn()
    }
}

extension ViewController: ServerDelegate {
    func onIncomingRequest(data: Any?) {
        logs.append(data)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
