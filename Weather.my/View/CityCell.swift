//
//  CityCell.swift
//  Weather.my
//
//  Created by Денис Андриевский on 26.07.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import UIKit

class CityCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView! {
        didSet {
            backView.layer.cornerRadius = 20.0
            backView.clipsToBounds = true
        }
    }
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
