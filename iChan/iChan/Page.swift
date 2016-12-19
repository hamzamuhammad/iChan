//
//  Page.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/18/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class Page: NSObject {
    
    private var _threadPreviews: [Post] = []
    
    var threadPreviews: [Post] {
        return _threadPreviews
    }
    
    func addPost(originalPost: Post) {
        _threadPreviews.append(originalPost)
    }
}
