//
//  ViewController.swift
//  Memrise-Tool
//
//  Created by Charlton Provatas on 10/16/16.
//  Copyright © 2016 Charlton Provatas. All rights reserved.
//

import Cocoa
import WebKit

let languages = [ "en", "af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca", "ceb", "ny", "zh-CN", "co", "hr", "cs", "da", "nl", "eo", "et", "tl", "fi", "fr", "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "iw", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km", "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "ps", "fa", "pl", "pt", "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk", "ur", "uz", "vi", "cy", "xh", "yi", "yo", "zu" ]



class ViewController: NSViewController {
    
    var webBrowser: WebBrowser!
    var translator: WKWebView!
    var urlTextBar: HandleEnterClass!
    var loadUrlButton: NSButton!
    var translateButton: NSButton!
    
    @IBOutlet var translateToSlider: NSPopUpButton!
    @IBOutlet var translateFromSlider: NSPopUpButton!
    @IBOutlet var resultsBox: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webBrowser = WebBrowser()
        webBrowser.navigationDelegate = self
        webBrowser.frame = NSRect(x: 0, y: 0, width: view.frame.size.width / 2, height: view.frame.size.height - 22)
        view.addSubview(webBrowser)
        
        urlTextBar = HandleEnterClass()
        urlTextBar.parent = self
        urlTextBar.frame = NSRect(x: 0, y: view.frame.size.height - 20, width: webBrowser.frame.size.width - 25, height: 20)
        view.addSubview(urlTextBar)
        
        loadUrlButton = NSButton()
        loadUrlButton.frame = NSRect(x: urlTextBar.frame.size.width, y: view.frame.size.height - 20, width: 25, height: 20)
        loadUrlButton.layer?.borderColor = NSColor.black.cgColor
        loadUrlButton.layer?.borderWidth = 2
        loadUrlButton.title  = "->"
        loadUrlButton.action = #selector(loadUrl)
        
        
        translateButton = NSButton()
        translateButton.keyEquivalentModifierMask = .command
        translateButton.keyEquivalent = "t"
        translateButton.frame = NSRect(x: view.frame.size.width - 100, y: 0, width: 100, height: 25)
        translateButton.layer?.borderColor = NSColor.black.cgColor
        translateButton.layer?.borderWidth = 2
        translateButton.title  = "Translate (⌘T)"
        translateButton.action = #selector(translate)
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
    
    public func loadUrl() {
        webBrowser.loadRequestWith(urlString: StringInterpolation.inspect(string: urlTextBar.stringValue))
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        
        if event.keyCode == 76 || event.keyCode == 36 {
            loadUrl()
        }
    }
    
    var selectedString: String!
    public func translate() {
        webBrowser.evaluateJavaScript("window.getSelection().toString()") { (data, error) in
            
            if self.translateToSlider.indexOfSelectedItem == self.translateFromSlider.indexOfSelectedItem {
                self.alert(with: "Languages Are The Same", buttonTitle: "OK", description: "Please select two different languages to translate")
                return
            }
            if data == nil || data as! String == "" {
                self.alert(with: "No Text Selected", buttonTitle: "OK", description: "Highlight text from the web view on the left before clicking Translate.")
                return
            }
            
            let webString =  "https://translate.google.com/#" + languages[self.translateFromSlider.indexOfSelectedItem] + "/" + languages[self.translateToSlider.indexOfSelectedItem] + "/" + (data as! String).encode()
            print(webString)
            
            self.setWeb()
            self.selectedString = (data as! String)
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
            if data != nil && data is String {
                self.setResultText(string: data as! String)
            }
            print(error)
        }
    }
    
    private func setResultText(string: String) {
        resultsBox.string?.append(selectedString + ", " + StringInterpolation.removeHTML(string: string) + "\n")
    }

}


extension ViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if webView.className == "Memrise_Tool.WebBrowser" {
            urlTextBar.stringValue = (webView.url?.absoluteString)!
        }else {
            getGoogleTranslateContents()
        }
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if webView.className == "Memrise_Tool.WebBrowser" {
            urlTextBar.stringValue = (webView.url?.absoluteString)!
        }
    }
}

class HandleEnterClass : NSTextField {
    
    var parent : ViewController!
    
    override func keyUp(with event: NSEvent) {
        
        if event.keyCode == 76 || event.keyCode == 36 {
            parent.loadUrl()
            NSLog("loading from text view")
        }
    }
}

class ResultBox : NSTextView {
    
    override func mouseDown(with event: NSEvent) {        
        if (string?.characters.count)! > 0 {
            NSPasteboard.general().clearContents()
            NSPasteboard.general().setString(string!, forType: NSStringPboardType)
            NSLog("copied to clipboard")
        }
        super.mouseDown(with: event)
    }
    
}

extension String {
    public func encode() -> String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
