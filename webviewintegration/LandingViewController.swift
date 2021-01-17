//
//  LandingViewController.swift
//  webviewintegration
//
//  Created by WAN Tung Lok on 5/12/2020.
//  Copyright © 2020 Robert Wan. All rights reserved.
//

import UIKit
import WebKit

class LandingViewController: ViewController, WKScriptMessageHandler, UITextFieldDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nativeLabelTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var webView: WKWebView!
    
    var webViewPoint: CGPoint?
    
    var messages: [String] = []
    
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
            self.textField.resignFirstResponder()
        }
    }
    
    @IBAction func onClearAllButtonClicked(_ sender: Any) {
        messages.removeAll()
        tableView.reloadData()
        self.webView.evaluateJavaScript("clearAll()") { result, error in
            guard error == nil else {
                print(error)
                return
            }
            self.textField.text = ""
            self.textField.resignFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "WebView Integration"

        textField.delegate = self

        tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        
        tableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true
        
        webViewPoint = webView.superview?.convert(webView.frame.origin, to: nil)
        
        if #available(iOS 14.0, *) {
            webView.configuration.userContentController.add(self, contentWorld: .page, name: "accenture")
        } else {
            webView.configuration.userContentController.add(self, name: "accenture")
        }
        
        if let url = URL(string: "http://192.168.27.213:3000") {
            webView.load(URLRequest(url: url))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        if (!textField.isFirstResponder) {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                if let point = webViewPoint {
                    var offset = point.y - (UIScreen.main.bounds.height - keyboardFrame.cgRectValue.height)
                    if (offset > 0) {
                        offset *= -1
                    }
                    nativeLabelTopLayoutConstraint.constant = offset
                }
            }
            webView.evaluateJavaScript("window.scrollTo(0,1)", completionHandler: nil)
        }
    }

    @objc func keyboardWillDisappear() {
        nativeLabelTopLayoutConstraint.constant = 16
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath)
        if let cell = cell as? MessageTableViewCell {
            cell.label.text = "\(messages[indexPath.row])"
        }
        return cell
    }
    
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        webView?.reload()
        sender.endRefreshing()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let data = message.body as? [String: String] else {
            return
        }
        if (message.name == "accenture") {
            if (data["action"] == "message") {
                if let message = data["content"] {
                    messages.append(message)
                }
                tableView.reloadData()
            } else if (data["action"] == "clearAll") {
                messages.removeAll()
                tableView.reloadData()
                textField.text = ""
                textField.resignFirstResponder()
            } else if (data["action"] == "camera") {
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
