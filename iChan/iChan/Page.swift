//
//  Page.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/22/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class Page: NSObject {
    
    private var threadPreviews: [Post] = []
    
    func getPost(index: Int) -> Post {
        return threadPreviews[index]
    }
    
    func addPost(post: Post) {
        threadPreviews.append(post)
    }
    
    func numPreviewThreads() -> Int {
        return threadPreviews.count
    }
}
