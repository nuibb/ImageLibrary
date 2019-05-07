//
//  ViewController.swift
//  ImageLoader
//
//  Created by Steve JobsOne on 4/17/19.
//  Copyright © 2019 MobioApp Limited. All rights reserved.
//

import UIKit

enum FileType: String {
    case json = "json"
    case xml = "xml"
    case pdf = "pdf"
    case zip = "zip"
}

enum HTTPRequestType : String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class ImageListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    var dataModel = DataModel()
    var imageContainer = [ImageInfo]()
    var dataArray = [ImageInfo]()
    let itemsToLoadOnEachPush = 10
    var lastFetchedIndex = 0
    
    func loadDataToTableView() {
        if self.lastFetchedIndex + self.itemsToLoadOnEachPush - 1 < self.imageContainer.count {
            for index in stride(from: self.lastFetchedIndex, to: self.lastFetchedIndex + self.itemsToLoadOnEachPush, by: 1) {
                self.dataArray.append(self.imageContainer[index])
            }
            self.lastFetchedIndex = self.lastFetchedIndex + self.itemsToLoadOnEachPush
            self.tableView.reloadData()
        }
    }
    
    func makeAPICallFor(requestType: HTTPRequestType, fileType: FileType, urlString: String) {
        if fileType == .json || fileType == .xml {
            if requestType == .get {
                //Get parsed data from server
                LibraryAPI.shared.getDataFromServer(urlString, completionBlock: { (parsedData) in
                    self.imageContainer = parsedData
                    self.loadDataToTableView()
                })
            } else {
                let parameters = [String:Any]()
                LibraryAPI.shared.getDataFromServer(urlString, parameters: parameters, httpRequestType: requestType.rawValue) { (data) in
                    print(data)
                }
            }
        } else if (fileType == .pdf || fileType == .zip) {
            //Make API call to download file contents like PDF/ZIP files from server
            LibraryAPI.shared.downloadFile(withUrl: urlString, fileType: .pdf)
        }
    }
    
    @objc private func refresh(_ sender: Any) {
        /*
         If server side has this feature, you can make API call again here to
         get new chunk of data with threshold from server after pull to refresh.
         Server need to accept fromIndex and batchSize in the API url as query param.
         Example : "http://pastebin.com//raw/wgkJgazE" + "&batchSize=" + batchSize + "&fromIndex=" + fromIndex
         */
        self.refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Image Library"
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to fetch more images")
        self.refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        
        // Configure Refresh Control
        self.refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = self.refreshControl
        } else {
            self.tableView.addSubview(self.refreshControl)
        }
        
        self.tableView.rowHeight = 120
        
        //Making Api Call to get json data drom server
        makeAPICallFor(requestType: .get, fileType: .json, urlString: PATH_FOR_JSON_DATA)
        
        //Making Api Call to download pdf file from server
        makeAPICallFor(requestType: .get, fileType: .pdf, urlString: PATH_FOR_PDF_FILE)
        
        
    }
}

extension ImageListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoaderCell", for: indexPath) as! ImageLoaderCell
        let imageInfo = self.dataArray[indexPath.row]
        let urls: ImageUrls = imageInfo.urls!
        let thumbUrl = urls.thumb!
        let user = imageInfo.user!
        cell.thumbImage.loadImageUsingCache(withUrl: thumbUrl)
        cell.publisherName.text = user.name!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let selectedCell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "showDetailsView", sender: indexPath)
    }
}

extension ImageListViewController {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if ((maximumOffset - currentOffset) < 10) {
            //Load more images here
            if self.lastFetchedIndex + self.itemsToLoadOnEachPush - 1 < self.imageContainer.count {
                for index in stride(from: self.lastFetchedIndex, to: self.lastFetchedIndex + self.itemsToLoadOnEachPush, by: 1) {
                    self.dataArray.append(self.imageContainer[index])
                }
                //Inserting more images into table view with animation
                var indexPathsArray = [IndexPath]()
                for index in self.lastFetchedIndex..<self.dataArray.count{
                    let indexPath = IndexPath(row: index, section: 0)
                    indexPathsArray.append(indexPath)
                }
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: indexPathsArray, with: UITableView.RowAnimation.fade)
                self.tableView.endUpdates()
                self.lastFetchedIndex = self.lastFetchedIndex + self.itemsToLoadOnEachPush
            } else {
                print("Don't have images to load more.")
            }
        }
    }
}

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        self.image = nil
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        // if not, download image from url
        LibraryAPI.shared.loadImage(withUrl: urlString) { (image) in
            imageCache.setObject(image, forKey: urlString as NSString)
            self.image = image
        }
    }
}

extension ImageListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsView" {
            let detailsViewController = segue.destination as! ImageDetailsViewController
            guard let indexPath = sender as? IndexPath else {return}
            print(self.dataArray[indexPath.row])
            let imageInfo = self.dataArray[indexPath.row]
            detailsViewController.imageId = imageInfo.id
        }
    }
}


