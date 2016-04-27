//
//  ThemeTableViewCell.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/27/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class ThemeTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var themeNameLabel: UILabel!
    
    @IBOutlet weak var startTestButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.contentView.backgroundColor = UIColor(red: 0.455, green: 0.365, blue: 0.816, alpha: 1.00)
        } else {
            self.contentView.backgroundColor = UIColor.init(white: 1, alpha: 0.2)
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            self.contentView.backgroundColor = UIColor(red: 0.455, green: 0.365, blue: 0.816, alpha: 1.00)
        } else {
            self.contentView.backgroundColor = UIColor.init(white: 1, alpha: 0.2)
        }
    }

}
