import UIKit
import Network

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
//    @IBAction func didTapWebview(_ sender: Any) {
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webview") as! WebviewController
//
//        if let url = serverUrl, var comp = URLComponents(url: url, resolvingAgainstBaseURL: true) {
//            comp.path = "/status"
//            vc.setDefault(url: comp.url!)
//        }
//        navigationController?.pushViewController(vc, animated: true)
//    }
}

//extension ViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell") else {
//            return UITableViewCell()
//        }
//
//        cell.textLabel?.text = ""
//        cell.detailTextLabel?.text = ""
//
//        return cell
//    }
//}
//
//extension ViewController: ConnectionDelegate {
//
//    func onIncoming(string: String) {
//        showAlert(message: string)
//    }
//}
