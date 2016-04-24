//
//  WordTableViewCell.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/21/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class WordTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var wordNumber: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translatedWordLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
