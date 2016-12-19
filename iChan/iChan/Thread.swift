//
//  Thread.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/18/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class Thread: NSObject {
    
    private var _posts: [Post] = []
    
    var posts: [Post] {
        return _posts
    }
    
    func addPost(post: Post) {
        _posts.append(post)
    }
}
