import UIKit
import Network

class ViewController: UIViewController {
    
    private lazy var browserListener: BrowserListener = BrowserListener(delegate: self)
    private var serverListener: ServerListener?
    
    private var serverEnabled: Bool = false {
        didSet {
            if serverEnabled {
                serverBtn.setTitle("Server is ON", for: .normal)
            } else {
                serverBtn.setTitle("Server is OFF", for: .normal)
            }
        }
    }
    
    @IBOutlet weak var clientBtn: UIButton!
    @IBOutlet weak var serverBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    
    private var listResult: [NWBrowser.Result] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func startServerListener() {
        serverListener?.start()
    }
    
    func startBrowsingServer() {
        browserListener.start()
    }
    
    @IBAction func didTapServer(_ sender: Any) {
        serverEnabled = !serverEnabled
        if serverEnabled {
            serverListener = try? ServerListener()
            startServerListener()
        } else {
            serverListener?.stop()
        }
    }
    
    @IBAction func didTapClient(_ sender: Any) {
        startBrowsingServer()
    }
}

extension ViewController: BrowserListenerDelegate {
    func refreshBrowser(with result: Set<NWBrowser.Result>) {
        listResult = Array(result)
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell") else {
            return UITableViewCell()
        }
        
        let result = listResult[indexPath.row]
        let endpoint = result.endpoint
        
        if case let .service(name, type, domain, interface) = endpoint {
            cell.textLabel?.text = "\(name)"
            cell.detailTextLabel?.text = "type:\(type), domain:\(domain), interface:\(String(describing: interface))"
        } else {
            cell.textLabel?.text = "\(result)"
        }
        
        return cell
    }
}
