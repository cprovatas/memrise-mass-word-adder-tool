//
//  WebView.swift
//  Memrise-Tool
//
//  Created by Charlton Provatas on 10/16/16.
//  Copyright © 2016 Charlton Provatas. All rights reserved.
//

import Foundation
import WebKit
import AppKit

class WebBrowser : WKWebView {
            
    override func viewDidMoveToWindow() {
        allowsBackForwardNavigationGestures = true
        customUserAgent = "Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5"
        loadRequestWith(urlString: "http://www.gazeta-shqip.com/lajme/")        
    }
    
    public func loadRequestWith(urlString: String) {
        if urlString == "" { return }
        
        load(URLRequest(url: URL(string: urlString)!))
        
    }
}
