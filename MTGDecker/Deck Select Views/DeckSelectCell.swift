//
//  DeckSelectCell.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/27/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

class DeckSelectCell: UITableViewCell{
    
    @IBOutlet weak var deckTitleLabel: UILabel!
    @IBOutlet weak var deckDetailLabel: UILabel!
    
    var deck: Deck? = nil
    
    func setNewDeck(_ newDeck: Deck){
        
        self.deck = newDeck
        
        if deck!.name != nil { deckTitleLabel.text = deck!.name }
        else { deckTitleLabel.text = "Unnamed Deck" }
        
        deckDetailLabel.text = deck!.summaryText()
        
    }//setDeck
    
    
    
}//DeckSelectCell
