//
//  DetailsViewController.swift
//  ImageLoader
//
//  Created by Steve JobsOne on 4/23/19.
//  Copyright © 2019 MobioApp Limited. All rights reserved.
//

import UIKit

class ImageDetailsViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    var imageId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let id = imageId {
            let imageItem = LibraryAPI.shared.getSavedImageBy(id: id)
            if let imageInfo = imageItem {
                let urls: ImageUrls = imageInfo.urls!
                let thumbUrl = urls.thumb!
                let user = imageInfo.user!
                self.detailImageView.loadImageUsingCache(withUrl: thumbUrl)
                self.userName.text = user.name!                
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
