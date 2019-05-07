//
//  TableViewCell.swift
//  BookListApp
//
//  Created by Steve JobsOne on 2/15/19.
//  Copyright © 2019 MobioApp Limited. All rights reserved.
//

import UIKit

class ImageLoaderCell: UITableViewCell {
    
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var publisherName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
