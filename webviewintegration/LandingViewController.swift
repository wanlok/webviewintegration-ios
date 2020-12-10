//
//  LandingViewController.swift
//  webviewintegration
//
//  Created by WAN Tung Lok on 5/12/2020.
//  Copyright © 2020 Robert Wan. All rights reserved.
//

import UIKit
import WebKit

class LandingViewController: ViewController, WKScriptMessageHandler, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

        textField.delegate = self
        
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
                viewController.delegate = self
                present(viewController, animated: true)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage, let base64String = image.jpegData(compressionQuality: 1)?.base64EncodedString() else {
            return
        }
        self.webView.evaluateJavaScript("addBase64StringImage('\("data:image/png;base64, \(base64String)")')") { result, error in
            guard error == nil else {
                print(error)
                return
            }
        }
    }
}
