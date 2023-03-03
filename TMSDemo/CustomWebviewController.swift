//
//  CustomWebviewController.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/3/23.
//

import UIKit
import WebKit

class CustomWebviewController: UIViewController {
    
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var textfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webview.navigationDelegate = self
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        guard let string = textfield.text,
                let url = URL(string: string) else {
            print("URL string failed!")
            return
        }
        
        webview.load(URLRequest(url: url))
    }
}

extension CustomWebviewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            print(host)
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("#webview finish")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
}
