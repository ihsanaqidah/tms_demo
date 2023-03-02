//
//  WebViewController.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/2/23.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var webview = WKWebView()
    let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webview)
        webview.frame = view.bounds
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        print(request)
        webview.load(request)
    }
}
