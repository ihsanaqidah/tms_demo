//
//  WebviewController.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/4/23.
//

import UIKit
import WebKit

class WebviewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        guard let url = URL(string: textField.text!) else {
            print("URL string NOT VALID!")
            return
        }
        
        let request = URLRequest(url: url)
        webview.load(request)
    }
}
