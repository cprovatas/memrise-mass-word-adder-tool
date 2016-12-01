//
//  StringInterpolation.swift
//  Memrise-Tool
//
//  Created by Charlton Provatas on 10/22/16.
//  Copyright © 2016 Charlton Provatas. All rights reserved.
//

import Foundation

class StringInterpolation {
    
    class func inspect(string: String) -> String {
        
        if !string.contains("http://") && !string.contains("https://") && !string.contains("www.") && !string.contains(".") {
            return "https://www.google.com/search?q=" + string.encode()
        }
        
        var candidate = URL(string: "https://" + string)
        
        if candidate?.scheme == nil || candidate?.host == nil {
            return "http://" + string
        }else if !string.contains("https://") {
            return "https://" + string
        }
        
        
        return string
    }
    
    class func removeHTML( string: String) -> String {
        
        var string = string
        let fragments = [ "<span>", "</span>", "<br>", "</br>", "<span title=\"", "\">" ]
        
        for fragment in fragments {
            string = string.replacingOccurrences(of: fragment, with: "")
        }
        return string
    }
}


//extension String {
//    
//    subscript (i: Int) -> Character {
//        return self[self.startIndex.advancedBy(i)]
//    }
//    
//    subscript (i: Int) -> String {
//        return String(self[i] as Character)
//    }
//    
//    subscript (r: Range<Int>) -> String {
//        let start = startIndex.advancedBy(r.startIndex)
//        let end = start.advancedBy(r.endIndex - r.startIndex)
//        return self[Range(start ..< end)]
//    }
//}
