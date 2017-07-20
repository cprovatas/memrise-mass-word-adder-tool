//
//  StringInterpolation.swift
//  Memrise-Tool
//
//  Created by Charlton Provatas on 10/22/16.
//  Copyright © 2016 Charlton Provatas. All rights reserved.
//

import Foundation

class StringInterpolation {
    
    public class func inspect(string: String) -> String {
                        
        if !string.contains("http://") && !string.contains("https://") && !string.contains("www.") && !string.contains(".") {
            return "https://www.google.com/search?q=" + string.encoded!
        }
        
        let candidate = URL(string: "https://" + string)
        
        if candidate?.scheme == nil || candidate?.host == nil {
            return "http://" + string
        }else if !string.contains("https://") {
            return "https://" + string
        }
        
        
        return string
    }
    
    public class func removeHTML(_ string: String) -> String {
        return ["<span>", "</span>", "<br>", "</br>", "<span title=\"", "\">"].map({ string.replacingOccurrences(of: $0, with: "") }).joined()
    }
}

