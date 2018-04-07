//
//  CardTableCell.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/27/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreGraphics

class CardTableCell: UITableViewCell{
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var quantityStepper: UIStepper!
    @IBOutlet var quantityLabel: UILabel!
    
    var card: MCard?
    var parentDeck: Deck?
    var quantity: Int = 0
    var cellPosition: IndexPath?
    
    func setCellCard(_ card: MCard){
        self.card = card
        
        nameLabel.text = self.card!.name

    }//setCellCard
    
    func setPath(_ path: IndexPath){
        self.cellPosition = path
    }
    
    func setDeck(_ deck: Deck){
        self.parentDeck = deck;
    }//setDeck
    
    func setCellQuantity(_ quant: Int){
        self.quantity = quant
        
        quantityLabel.text = "\(self.quantity)"
        
        quantityStepper.value = Double(quant)
        
        //TODO: change minimum quantity to 0; handle removal better
        quantityStepper.minimumValue = 0
        quantityStepper.maximumValue = 100
        quantityStepper.autorepeat = true
        
    }//setCellQuantity
    
    //MARK: Stepper Button Functions
    
    @IBAction func quantityChanged(_ sender: UIStepper) {
        let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let oldQuantity: Int = self.quantity
        let newQuantity: Int = Int(sender.value)
        
        let diff: Int = newQuantity - oldQuantity
        
        if (newQuantity == 0){
            self.removeCardCell()
            return
        }
        
        if (diff > 0){
            for _ in 1...diff{
                parentDeck!.addCard(self.card!, context: context)
            }//for each card to add
            self.quantity = newQuantity
            quantityLabel.text = "\(self.quantity)"
        }//if adding cards
        if (diff < 0){
            for _ in -1...diff{
                let successfulRemove = parentDeck!.removeCard(self.card!, context: context)
                if (!successfulRemove){
                    NSLog("Error in removing card")
                }
            }//for
            self.quantity = newQuantity
            quantityLabel.text = "\(self.quantity)"
        }//if removing cards

        
    }//quantityChanged
    
    func removeCardCell(){

        NotificationCenter.default.post(name: .cardCellRemoveNotification, object: self)
    }//removeCardCell
    
    
}//CardTableCell
