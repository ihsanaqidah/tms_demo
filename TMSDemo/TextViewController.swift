//
//  TextViewController.swift
//  TMSDemo
//
//  Created by Ihsan Husnul Aqidah on 3/7/23.
//

import UIKit

class TextViewController: UIViewController {
    
    @IBOutlet weak var textview: UITextView!
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textview.text = text
    }
}
