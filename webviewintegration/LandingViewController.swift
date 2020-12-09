//
//  LandingViewController.swift
//  webviewintegration
//
//  Created by WAN Tung Lok on 5/12/2020.
//  Copyright © 2020 Robert Wan. All rights reserved.
//

import UIKit
import WebKit

class LandingViewController: ViewController, WKScriptMessageHandler {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    
    @IBAction func onAddButtonClicked(_ sender: Any) {
        guard let value = textField.text, value.count > 0 else {
            return
        }
        self.webView.evaluateJavaScript("addItem('\(value)')") { result, error in
            guard error == nil else {
                print(error)
                return
            }
            self.textField.text = ""
        }
    }
    
    @IBAction func onClearAllButtonClicked(_ sender: Any) {
        self.webView.evaluateJavaScript("clearAll()") { result, error in
            guard error == nil else {
                print(error)
                return
            }
            self.textField.text = ""
        }
    }
    
    var htmlString = """

    """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "WebView Integration Demo"

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true
        
        if #available(iOS 14.0, *) {
            webView.configuration.userContentController.add(self, contentWorld: .page, name: "accenture")
        } else {
            webView.configuration.userContentController.add(self, name: "accenture")
        }
        
        if let url = URL(string: "http://192.168.27.213:3000") {
            webView.load(URLRequest(url: url))
        }
        
//        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    @objc
    func refreshWebView(_ sender: UIRefreshControl) {
        webView?.reload()
        sender.endRefreshing()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let data = message.body as? [String: String] else {
            return
        }
        if (message.name == "accenture") {
            if (data["action"] == "camera") {
                let viewController = UIImagePickerController()
                viewController.sourceType = .camera
                viewController.allowsEditing = true
//                viewController.delegate = self
                present(viewController, animated: true)
            }
        }
    }
}
