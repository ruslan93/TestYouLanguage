//
//  ResultTableViewCell.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/22/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rightAnswerLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
