//
//  ImageInfo.swift
//  ImageLoader
//
//  Created by Steve JobsOne on 4/17/19.
//  Copyright © 2019 MobioApp Limited. All rights reserved.
//

import UIKit

class ImageInfo: NSObject {    
    var height: Int?
    var liked_by_user: Int?
    var color: String?
    var user: User?
    var likes: Int?
    var id: String?
    var current_user_collections: [[String:Any]]?
    var urls: ImageUrls?
    var links: ImageLinks?
    var categories: [ImageCategory]?
    var created_at: String?
    var width: Int?
}
