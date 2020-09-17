//
//  CustomTableViewCell.swift
//  Flick+
//
//  Created by ikei6256 on 2020/05/31.
//  Copyright © 2020 ikei_org. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var crownImageView: UIImageView!
    let difficultyList:[String] = ViewController().difficultyList

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // セル設定の処理
    func cellManage( indexPath:IndexPath, rankings:[RankingViewController.ScoreData], difficultyNum:Int){
        if( indexPath.row == 0 ){
            // 1位
            self.crownImageView.image = UIImage(named: "gold")
            self.cellLabel.text = String( rankings[ difficultyNum ].scores[indexPath.row] ) + " pts"
        }else if( indexPath.row == 1 ){
            // 2位
            self.crownImageView.image = UIImage(named: "silver")
            self.cellLabel.text = String( rankings[ difficultyNum ].scores[indexPath.row] ) + " pts"
        }else if( indexPath.row == 2 ){
            // 3位
            self.crownImageView.image = UIImage(named: "copper")
            self.cellLabel.text = String( rankings[ difficultyNum ].scores[indexPath.row] ) + " pts"
        }else{
            // 4位-
            self.crownImageView.removeConstraints( self.crownImageView.constraints )
            self.crownImageView.isHidden = true

            self.cellLabel.translatesAutoresizingMaskIntoConstraints = false
            self.cellLabel.leftAnchor.constraint(equalTo: self.leftAnchor , constant: 20).isActive = true
            self.cellLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.cellLabel.text = String( (indexPath.row)+1 ) + "位   "
                + String( rankings[ difficultyNum ].scores[indexPath.row] ) + " pts"
        }
    }
}
