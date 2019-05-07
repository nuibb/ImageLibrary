//
//  DataParser.swift
//  ImageLoader
//
//  Created by Steve JobsOne on 4/17/19.
//  Copyright © 2019 MobioApp Limited. All rights reserved.
//

import UIKit

class DataModel: NSObject {
    fileprivate func extractedFunc(_ categories: [[String : Any]], _ imageCategories: inout [ImageCategory]) {
        for category in categories {
            
            guard let id = category["id"] as? Int else {print("2");return}
            guard let links = category["links"] as? [String: Any] else {print("3");return}
            guard let photo_count = category["photo_count"] as? Int else {print("4");return}
            guard let title = category["title"] as? String else {print("5");return}
            
            let imageCategory = ImageCategory()
            imageCategory.id = id
            imageCategory.photo_count = photo_count
            imageCategory.title = title
            
            guard let links_photos = links["photos"] as? String else {print("6");return}
            guard let links_self = links["self"] as? String else {print("7");return}
            let imageCategoryLinks = ImageCategoryLinks()
            imageCategoryLinks.photos = links_photos
            imageCategoryLinks._self = links_self
            
            imageCategory.links = imageCategoryLinks
            
            imageCategories.append(imageCategory)
        }
    }
    
    func parseJsonDataForImages(json:Any, completionBlock: (([ImageInfo]) -> Void)!) {

        guard let jsonArray = json as? [[String:Any]] else {return}
        var imageContainer = [ImageInfo]()
        
        for item in jsonArray {
            
            //print("jsonArray : \(item)")
            
            let imageInfo = ImageInfo()
            
            guard let categories = item["categories"] as? [[String: Any]] else {print("1");return}
            
            var imageCategories = [ImageCategory]()
            
            extractedFunc(categories, &imageCategories)
            
            imageInfo.categories = imageCategories
            
            guard let created_at = item["created_at"] as? String else {print("8");return}
            imageInfo.created_at = created_at
            guard let width = item["width"] as? Int else {print("9");return}
            imageInfo.width = width
            guard let current_user_collections = item["current_user_collections"] as? [[String: Any]] else {print("10");return}
            imageInfo.current_user_collections = current_user_collections
            guard let height = item["height"] as? Int else {print("11");return}
            imageInfo.height = height
            guard let id = item["id"] as? String else {print("12");return}
            imageInfo.id = id
            
            guard let user = item["user"] as? [String: Any] else {print("13");return}
            guard let user_id = user["id"] as? String else {print("14");return}
            guard let user_links = user["links"] as? [String: Any] else {print("15");return}
            guard let user_name = user["name"] as? String else {print("16");return}
            guard let user_profile_image = user["profile_image"] as? [String: Any] else {print("17");return}
            guard let user_username = user["username"] as? String else {print("18");return}
            
            let imageUser = User()
            imageUser.id = user_id
            imageUser.name = user_name
            imageUser.username = user_username
            
            guard let user_links_html = user_links["html"] as? String else {print("19");return}
            guard let user_links_likes = user_links["likes"] as? String else {print("20");return}
            guard let user_links_photos = user_links["photos"] as? String else {print("21");return}
            guard let user_links_self = user_links["self"] as? String else {print("22");return}
            
            let userLinks = UserLinks()
            userLinks.html = user_links_html
            userLinks.likes = user_links_likes
            userLinks.photos = user_links_photos
            userLinks._self = user_links_self
            
            imageUser.links = userLinks
            
            guard let user_profile_image_large = user_profile_image["large"] as? String else {print("23");return}
            guard let user_profile_image_medium = user_profile_image["medium"] as? String else {print("24");return}
            guard let user_profile_image_small = user_profile_image["small"] as? String else {print("25");return}
            
            let userProfileImage = UserProfileImage()
            userProfileImage.large = user_profile_image_large
            userProfileImage.medium = user_profile_image_medium
            userProfileImage.small = user_profile_image_small
            
            imageUser.profile_image = userProfileImage
            
            imageInfo.user = imageUser
            
            guard let color = item["color"] as? String else {print("26");return}
            imageInfo.color = color
            guard let likes = item["likes"] as? Int else {print("27");return}
            imageInfo.likes = likes
            guard let liked_by_user = item["liked_by_user"] as? Int else {print("28");return}
            imageInfo.liked_by_user = liked_by_user
            
            guard let urls = item["urls"] as? [String:Any] else {print("29");return}
            guard let urls_full = urls["full"] as? String else {print("30");return}
            guard let urls_raw = urls["raw"] as? String else {print("31");return}
            guard let urls_regular = urls["regular"] as? String else {print("32");return}
            guard let urls_small = urls["small"] as? String else {print("33");return}
            guard let urls_thumb = urls["thumb"] as? String else {print("34");return}
            
            let imageUrls = ImageUrls()
            imageUrls.full = urls_full
            imageUrls.raw = urls_raw
            imageUrls.regular = urls_regular
            imageUrls.small = urls_small
            imageUrls.thumb = urls_thumb
            
            imageInfo.urls = imageUrls
            
            guard let links = item["links"] as? [String:Any] else {print("35");return}
            guard let links_download = links["download"] as? String else {print("36");return}
            guard let links_html = links["html"] as? String else {print("37");return}
            guard let links_self = links["self"] as? String else {print("38");return}
            
            let imageLinks = ImageLinks()
            imageLinks.download = links_download
            imageLinks.html = links_html
            imageLinks._self = links_self
            
            imageInfo.links = imageLinks
            
            imageContainer.append(imageInfo)
        }
        
        completionBlock(imageContainer)
    }
}
