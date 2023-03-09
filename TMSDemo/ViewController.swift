import UIKit
import Network

var isWebsocketEnabled: Bool = false

class ViewController: UIViewController {
    
    @IBOutlet weak var websocketBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "v\(Bundle.main.versionNumber) (\(Bundle.main.buildNumber))"
    }
    
    @IBAction func didTapWebsocket(_ sender: Any) {
        isWebsocketEnabled = !isWebsocketEnabled
        if isWebsocketEnabled {
            websocketBtn.setTitle("Turn Off Websocket", for: .normal)
        } else {
            websocketBtn.setTitle("Turn On Websocket", for: .normal)
        }
    }
}

extension Bundle {
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }
}
