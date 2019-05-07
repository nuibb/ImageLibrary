//
//  PersistencyManager.swift
//  ImageLoader
//
//  Created by Guest User on 4/21/19.
//  Copyright © 2019 MobioApp Limited. All rights reserved.
//

import Foundation
import UIKit

final class PersistencyManager {
    private var imageInfoList = [ImageInfo]()
    
    init() {
        //Dummy list of Images
        
    }
    
    func getImageList() -> [ImageInfo] {
        return imageInfoList
    }
    
    func setImageList(imageList: [ImageInfo]) {
        self.imageInfoList = imageList
    }
    
    func addImageIntoList(_ imageInfo: ImageInfo, at index: Int) {
        if (imageInfoList.count >= index) {
            imageInfoList.insert(imageInfo, at: index)
        } else {
            imageInfoList.append(imageInfo)
        }
    }
    
    func deleteImageFromList(at index: Int) {
        imageInfoList.remove(at: index)
    }
    
    private var cache: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    
    func saveImage(_ image: UIImage, filename: String) {
        let url = cache.appendingPathComponent(filename)
        guard let data = image.pngData() else {
            return
        }
        try? data.write(to: url, options: [])
    }
    
    func getImage(with filename: String) -> UIImage? {
        let url = cache.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    func saveFile(_ location: URL, filename: String, fileType: String) {
        do {
            let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
            let savedURL = documentsURL.appendingPathComponent("\(filename).\(fileType)")
            if !savedURL.isFileExist() {
                try FileManager.default.moveItem(at: location, to: savedURL)
            } else {
                print("\(filename).\(fileType) is already exists in document directory.")
            }
        } catch {
            print ("file error: \(error)")
        }
    }
}

extension URL {
    func isFileExist() -> Bool {
        let path = self.path
        if (FileManager.default.fileExists(atPath: path))   {
            return true
        } else {
            return false;
        }
    }
}
