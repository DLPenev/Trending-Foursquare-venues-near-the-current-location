//
//  VenueTableViewCell.swift
//  TrendingVenues
//
//  Created by Dobromir Penev on 24.11.19.
//  Copyright © 2019 Dobromir Penev. All rights reserved.
//

import UIKit

class VenueTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
