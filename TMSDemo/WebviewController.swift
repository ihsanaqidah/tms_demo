//
//  WebviewController.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/3/23.
//

import UIKit
import WebKit

class WebviewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var goBtn: UIButton!
    private(set) var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webview.navigationDelegate = self
        loadWebview()
    }
    
    func set(url: URL?) {
        self.url = url
    }
    
    @IBAction func didTapGo(_ sender: Any) {
        self.url = URL(string: addressField.text ?? "")
        loadWebview()
    }
    
    func loadWebview() {
        guard let _url = url else {
            print("Invalid URL")
            return
        }
        print("URL \(_url.absoluteString)")
        
        let request = URLRequest(url: _url)
        webview.load(request)
    }
}
