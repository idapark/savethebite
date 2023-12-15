//
//  CustomTableViewCell.swift
//  SaveTheBite
//
//  Created by Ida Parkkali on 15.11.2023.
//
// used to initialize a custom cell object

import UIKit


class CustomTableViewCell: UITableViewCell {
    
    // @IBOutlet connects a UILabel in the storyboard to the customCellLabel property
    // This label can be used to display text information in the cell
    @IBOutlet weak var customCellLabel: UILabel!
    
    // @IBOutlet connects a UIImageView in the storyboard to the customCellPicture property
    // This image view can be used to display images in the cell
    @IBOutlet weak var customCellPicture: UIImageView!

}
 
