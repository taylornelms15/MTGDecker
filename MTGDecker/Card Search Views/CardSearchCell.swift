//
//  CardSearchCell.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/27/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

class CardSearchCell: UITableViewCell{
    
    @IBOutlet weak var cardTitleLabel: UILabel!
    @IBOutlet var addToDeckButton: UIButton!
    
    var cardCellDelegate: CardSearchViewController? = nil
    var isPressed: Bool = false
    var cellCardName: String = ""
    var cellPosition: IndexPath?
    
    func setCardName(name: String, delegate: CardSearchViewController, isPressed: Bool, atPath: IndexPath){
        
        cardTitleLabel.text = name
        self.cellCardName = name
        self.cardCellDelegate = delegate
        self.cellPosition = atPath
        
        addToDeckButton.layer.cornerRadius = 5.0
        addToDeckButton.layer.borderWidth = 1.0
        addToDeckButton.layer.borderColor = UIColor.black.cgColor
        addToDeckButton.contentEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6)
        
        
        
        if isPressed{
            self.setToPressed()
        }
        else{
            self.setToNotPressed()
        }
        
    }//setCardName
    
    @IBAction func addToDeckButtonPressed(_ sender: UIButton) {
        
        if(!isPressed){
            self.setToPressed()
            cardCellDelegate!.respondToCardAddPress(name: self.cellCardName)
        }
        else{
            self.setToNotPressed()
            cardCellDelegate?.respondToCardRemovePress(name: self.cellCardName)
        }
        
    }//addToDeckButtonPressed
    
    func setToPressed(){
        isPressed = true
        addToDeckButton.setTitle("Remove", for: .normal)
        addToDeckButton.backgroundColor = UIColor.darkGray
        addToDeckButton.setTitleColor(UIColor.lightText, for: .normal)
    }//setToPressed
    
    func setToNotPressed(){
        isPressed = false
        addToDeckButton.setTitle("Add to Deck", for: .normal)
        addToDeckButton.backgroundColor = UIColor.lightGray
        addToDeckButton.setTitleColor(UIColor.darkText, for: .normal)
    }//setToNotPressed
    
    
}//cardSearchCell
