//
//  LibraryAPI.swift
//  ImageLoader
//
//  Created by Guest User on 4/21/19.
//  Copyright © 2019 MobioApp Limited. All rights reserved.
//

import Foundation
import UIKit

final class LibraryAPI {
    
    static let shared = LibraryAPI()
    private let persistencyManager = PersistencyManager()
    private let httpClient = HTTPClient()
    private let isOnline = Reachability.isConnectedToNetwork()
    let dataModel = DataModel()
    
    private init() {
        self.httpClient.delegate = self
    }
    
    func getSavedImageBy(id: String) -> ImageInfo? {
        let imageList = self.getImageList()
        let results = imageList.filter { $0.id == id }
        if results.count > 0 {
            return results[0]
        } else {
            return nil
        }
    }
    
    func getSavedImage(fileName: String) -> UIImage? {
        if let cachedImage = self.imageCache.object(forKey: fileName as NSString) as? UIImage {
            return cachedImage
        }
        return nil
    }
    
    func getImageList() -> [ImageInfo] {
        return persistencyManager.getImageList()
    }
    
    func addImage(_ imageInfo: ImageInfo, at index: Int) {
        self.persistencyManager.addImageIntoList(imageInfo, at: index)
        if isOnline {
            //httpClient.postRequest()
        }
    }
    
    func deleteImage(at index: Int) {
        self.persistencyManager.deleteImageFromList(at: index)
        if isOnline {
            //httpClient.postRequest()")
        }
    }
    
    //For GET request
    func getDataFromServer(_ urlString: String, completionBlock: (([ImageInfo]) -> Void)!) {
        if isOnline {
            DispatchQueue.global().async {
                self.httpClient.getRequest(urlString, completionBlock: {(json) in
                    //Now parsing this json by writing a method in DataModel class & returning to invoking class
                    self.dataModel.parseJsonDataForImages(json: json, completionBlock: { (parsedData) in
                        DispatchQueue.main.async {
                            self.persistencyManager.setImageList(imageList: parsedData)
                            completionBlock(parsedData)
                        }
                    })
                })
            }
        } else {
            print("You are currently in offline mode. Please connect to Internet!")
        }
    }
    
    //For POST request
    func getDataFromServer(_ urlString: String, parameters: [String:Any], httpRequestType:String, completionBlock: @escaping (_ success: Any) -> Void) {
        if isOnline {
            DispatchQueue.global().async {
                self.httpClient.postRequest(urlString, parameters: parameters, httpRequestType: httpRequestType, completionBlock: {(json) in
                    //Now parse this json here by writing a method in DataModel class with your requirement
                    DispatchQueue.main.async {
                        //return parsed json object here
                    }
                })
            }
        } else {
            print("You are currently in offline mode. Please connect to Internet!")
        }
    }
    
    func downloadFile(withUrl urlString:String, fileType:FileType) {
        if isOnline {
            DispatchQueue.global().async {
                self.httpClient.downloadFile(urlString, fileType: fileType)
            }
        }else {
            print("You are currently in offline mode. Please connect to Internet!")
        }
    }
    
    func downloadImage(withUrl urlString : String, completionBlock: ((UIImage) -> Void)!) {
        guard let filename = URL(string: urlString)?.lastPathComponent else {return}
        let task = self.httpClient.downloadImage(urlString) { (image) in
            self.imageCache.setObject(image, forKey: filename as NSString)
            completionBlock(image)
        }
        
        //For cancelling download
        task?.cancel()// Need a feedback, from which state, image download would be canceled, after that this can be correctly implemented
    }
    
    //This will ensure the cache have a configurable max capacity and should evict images not recently used. It is a
    //mutable collection to temporarily store transient key-value pairs that are subject to eviction when resources are low.
    let imageCache = NSCache<NSString, AnyObject>()
    
    func loadImage(withUrl urlString : String, completionBlock: ((UIImage) -> Void)!) {
        guard let filename = URL(string: urlString)?.lastPathComponent else {return}
        
        //Load image from cache directory If image is already saved in cache directory
        /*if let savedImage = persistencyManager.getImage(with: filename) {
         completionBlock(savedImage)
         return
         }*/
        
        // Caching image here
        if let cachedImage = self.imageCache.object(forKey: filename as NSString) as? UIImage {
            completionBlock(cachedImage)
            return
        }
        
        // if not, download image from url & cache it
        if isOnline {
            //This will ensure, same image will be returned by multiple sources simultaneously
            DispatchQueue.global().async {
                let downloadedImage = self.httpClient.downloadImage(urlString) ?? UIImage()
                DispatchQueue.main.async {
                    completionBlock(downloadedImage)
                    //self.persistencyManager.saveImage(downloadedImage, filename: filename)
                    self.imageCache.setObject(downloadedImage, forKey: filename as NSString)
                }
            }
        } else {
            print("You are currently in offline mode. Please connect to Internet!")
        }
    }
}

extension LibraryAPI: FileDownloader {
    func getFileLocationPath(location: URL, filename: String, fileType: String) {
        self.persistencyManager.saveFile(location, filename: filename, fileType: fileType)
    }
}
