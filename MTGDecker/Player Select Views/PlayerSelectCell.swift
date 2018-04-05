//
//  PlayerSelectCell.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/27/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

class PlayerSelectCell: UITableViewCell{
    var player: Player? = nil
    @IBOutlet weak var playerNameLabel: UILabel!
    
    /**
     Sets the player. Also functions as a sort of "initializing" feature
     */
    func setPlayer(player: Player){
        
        self.player = player
        
        playerNameLabel.text = player.name
        
        
    }//setPlayer
 
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if selected{
            playerNameLabel.textColor = UIColor.darkText
            self.backgroundColor = UIColor.lightGray
        }//is selected
        else{
            self.backgroundColor = UIColor.darkGray
            playerNameLabel.textColor = UIColor.lightText
        }
    }
    
    
}//PlayerSelectCell
