//
//  ViewController.swift
//  Memrise-Tool
//
//  Created by Charlton Provatas on 10/16/16.
//  Copyright © 2016 Charlton Provatas. All rights reserved.
//

import Cocoa
import WebKit

final class CPMainViewController: NSViewController {
    
    private var webBrowser: CPWebView!
    private var translator: WKWebView!
    fileprivate var urlTextBar: CPTextField!
    private var selectedString: String!
    @IBOutlet private var translateToSlider: NSPopUpButton!
    @IBOutlet private var translateFromSlider: NSPopUpButton!
    @IBOutlet private var resultsBox: NSTextView!
    
    private var loadUrlButton: NSButton! = {
        let l = NSButton()
        l.layer?.borderColor = NSColor.black.cgColor
        l.layer?.borderWidth = 2
        l.title  = "->"
        l.action = NSSelectorFromString("loadUrl")
        return l
    }()
    
    private var translateButton: NSButton! = {
        let t = NSButton()
        t.keyEquivalentModifierMask = NSEvent.ModifierFlags.command
        t.keyEquivalent = "t"
        t.layer?.borderColor = NSColor.black.cgColor
        t.layer?.borderWidth = 2
        t.title  = "Translate (⌘T)"
        t.action = NSSelectorFromString("translate")
        return t
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        
        webBrowser = CPWebView()
        webBrowser.navigationDelegate = self
        webBrowser.frame = NSRect(x: 0, y: 0, width: view.frame.size.width / 2, height: view.frame.size.height - 22)
        view.addSubview(webBrowser)
        
        urlTextBar = CPTextField()
        urlTextBar.parent = self
        urlTextBar.frame = NSRect(x: 0, y: view.frame.size.height - 20, width: webBrowser.frame.size.width - 25, height: 20)
        view.addSubview(urlTextBar)
        
        loadUrlButton.frame = NSRect(x: urlTextBar.frame.size.width, y: view.frame.size.height - 20, width: 25, height: 20)
        translateButton.frame = NSRect(x: view.frame.size.width - 100, y: 0, width: 100, height: 25)
        view.addSubview(translateButton)
        view.addSubview(loadUrlButton)
    }
    
    private func setWeb() {
        if translator != nil { translator.removeFromSuperview() }
        translator = WKWebView()
        translator.navigationDelegate = self
        translator.frame = NSZeroRect
        view.addSubview(translator)
    }
    
    @objc public func loadUrl() {
        webBrowser.loadRequestWith(urlString: StringInterpolation.inspect(string: urlTextBar.stringValue))
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        
        if event.keyCode == 76 || event.keyCode == 36 {
            loadUrl()
        }
    }
    
    public func translate() {
        webBrowser.evaluateJavaScript("window.getSelection().toString()") { (data, error) in
            
            guard self.translateToSlider.indexOfSelectedItem != self.translateFromSlider.indexOfSelectedItem else {
                self.alert(with: "Languages Are The Same", buttonTitle: "OK", description: "Please select two different languages to translate")
                return
            }
            
            guard let html = data as? String, !html.isEmpty else {
                self.alert(with: "No Text Selected", buttonTitle: "OK", description: "Highlight text from the web view on the left before clicking Translate.")
                return
            }
            
            guard let encodedHTML = html.encoded else {
                Swift.print("\(self.self) Error Function: '\(#function)' Line \(#line).  Invalid HTML")
                return
            }
            
            let languages = CPGlobals.defaultLanguages
            
            let webString = "https://translate.google.com/#" + languages[self.translateFromSlider.indexOfSelectedItem] + "/" + languages[self.translateToSlider.indexOfSelectedItem] + "/" + encodedHTML
            
            //print(webString)
            
            self.setWeb()
            self.selectedString = html
            self.translator.load(URLRequest(url: URL(string: webString)!))
        }
    }
    
    private func alert(with title: String, buttonTitle: String, description: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.addButton(withTitle: buttonTitle)
        alert.informativeText = description
        alert.runModal()
    }
    
    public func getGoogleTranslateContents() {
        translator.evaluateJavaScript("document.getElementById(\"result_box\").innerHTML") { (data, error) in
            guard let data = data as? String else {
                Swift.print("\(self.self) Error Function: '\(#function)' Line \(#line).  Failed to get result")
                return
            }
            self.setResultText(string: data)
        }
    }
    
    private func setResultText(string: String) {
        resultsBox.string.append(selectedString + ", " + StringInterpolation.removeHTML(string) + "\n")
    }
}

extension CPMainViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Swift.print("\(self.self) Error Function: '\(#function)' Line \(#line).  \(error.localizedDescription)")
        print(error)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if let urlString = (webView as? CPWebView)?.url?.absoluteString {
            urlTextBar.stringValue = urlString
        }else {
            getGoogleTranslateContents()
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Swift.print("\(self.self) Error Function: '\(#function)' Line \(#line).  \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let urlString = (webView as? CPWebView)?.url?.absoluteString {
            urlTextBar.stringValue = urlString
        }
    }
}

class CPTextField : NSTextField {
    
    fileprivate weak var parent : CPMainViewController!
    override func keyUp(with event: NSEvent) {
        
        if event.keyCode == 76 || event.keyCode == 36 {
            parent.loadUrl()
        }
    }
}

class CPTextView : NSTextView {
    
    override func mouseDown(with event: NSEvent) {
        
        if !string.isEmpty {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(string, forType: .string)
        }
        
        super.mouseDown(with: event)
    }
    
}

public extension String {
    public var encoded : String? {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}
