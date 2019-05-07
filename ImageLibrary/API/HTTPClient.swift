//
//  HTTPClient.swift
//  ImageLoader
//
//  Created by Guest User on 4/21/19.
//  Copyright © 2019 MobioApp Limited. All rights reserved.
//

import Foundation
import UIKit

protocol FileDownloader {
    func getFileLocationPath(location: URL, filename: String, fileType: String)
}

class HTTPClient: NSObject {
    
    var delegate: FileDownloader?
    var urlPath: String?
    var fileType: FileType?
    
    func getRequest(_ urlString: String, completionBlock: ((Any) -> Void)!) {
        guard let url = URL(string: urlString) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return}
            do {
                //Here json is received as any kind of Foundation objects from a network request
                let json = try JSONSerialization.jsonObject(with:dataResponse, options: .allowFragments)
                DispatchQueue.main.async {
                    completionBlock(json)
                }
            } catch let parsingError {
                print("Parsing Error : ", parsingError)
            }
        }        
        task.resume()
    }
    
    func postRequest(_ urlString: String, parameters: [String:Any], httpRequestType:String, completionBlock: @escaping (_ success: Any) -> Void) {
        //create the session object
        let session = URLSession.shared
        
        //now create the NSMutableRequest object using the url object
        guard let url = URL(string: urlString) else {return}
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "\(httpRequestType)"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return}
            
            do {
                //Here json is received as any kind of Foundation objects from a network request
                let json = try JSONSerialization.jsonObject(with:dataResponse, options: .allowFragments)
                DispatchQueue.main.async {
                    completionBlock(json)
                }
                
            } catch let parsingError {
                print("Parsing Error : ", parsingError)
            }
        })
        
        task.resume()
    }
    
    func downloadImage(_ urlString: String, completionBlock: ((UIImage) -> Void)!) -> URLSessionDataTask? {
        guard let url = URL(string: urlString) else {return nil}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return}
            let image = UIImage(data: dataResponse)
            completionBlock(image!)
        }
        
        task.resume()
        
        return task
    }
    
    func downloadImage(_ urlString: String) -> UIImage? {
        let url = URL(string: urlString)
        guard let data = try? Data(contentsOf: url!),
            let image = UIImage(data: data) else {
                return nil
        }
        return image
        
        //For cancelling download, Your load() function needs to return the NSURLSessionDataTask you created. You then call task.cancel() to cancel the request
    }
    
    func downloadFile(_ urlString:String, fileType:FileType) {
        self.urlPath = urlString
        self.fileType = fileType
        guard let url = URL(string: urlString) else {return}
        let config = URLSessionConfiguration.default
        //config.httpMaximumConnectionsPerHost = 10
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
}

extension HTTPClient:  URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let filename = URL(string: self.urlPath!)?.lastPathComponent else {return}
        guard let fileType = fileType else {return}
        self.delegate?.getFileLocationPath(location: location, filename: filename, fileType: fileType.rawValue)
    }
}
