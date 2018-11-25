//
//  SketchViewCell.swift
//  GSketch
//
//  Created by user on 11/25/18.
//  Copyright © 2018 user. All rights reserved.
//

import UIKit

class SketchViewCell: UITableViewCell {

    @IBOutlet weak var imageContent: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
