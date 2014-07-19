//
//  BoxOfficeTableViewCell.swift
//  BoxOffice
//
//  Created by Ben Lindsey on 7/19/14.
//  Copyright (c) 2014 Ben Lindsey. All rights reserved.
//

import UIKit

class MovieTableViewCell : UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView.frame.origin = CGPoint(x: 10.0, y: 10.0)

        self.textLabel.frame.origin = CGPoint(x: 70.0, y: 10.0)
        self.textLabel.frame.size.width = 250.0

        self.detailTextLabel.frame.origin.x = 70.0
        self.detailTextLabel.frame.size.width = 250.0
        self.detailTextLabel.numberOfLines = 3
        self.detailTextLabel.sizeToFit()
    }
}
