//
//  CheckedInTableViewCell.swift
//  Check-In
//
//  Created by Book Lailert on 7/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit

class CheckedInTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        checkOutButtonOut.layer.cornerRadius = 7
        checkOutButtonOut.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet var checkOutButtonOut: UIButton!
    
    @IBOutlet var PlaceName: UILabel!
    @IBOutlet var Time: UILabel!
    
}
