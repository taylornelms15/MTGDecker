//
//  DeckSelectViewController.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/27/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DeckSelectViewController: UITableViewController{
    
    @IBOutlet weak var addDeckButton: UIBarButtonItem!
    @IBOutlet var deckSelectTable: DeckSelectTableView!
    
    
    var currentPlayer: Player?
    var deckList: [Deck]?
    var context: NSManagedObjectContext?
    
    override func viewDidLoad() {
        
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    }//viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDeckList()
        deckSelectTable.reloadData()
    }


    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (addDeckButton == (sender as? UIBarButtonItem) ){
            //make a new deck
            let newDeck: Deck = Deck(context: context!)
            newDeck.name = "Unnamed Deck"
            newDeck.id = Deck.getUniqueId(context: context!)
            
            currentPlayer!.deckList!.insert(newDeck)
            currentPlayer!.activeDeck = newDeck
            
            do{
                try context!.save()
            }
            catch{
                NSLog("Error adding new deck: \(error)")
            }
            
            (segue.destination as! DeckDetailViewController).deck = newDeck
            
        }//if adding a new deck
        
        switch sender{
        case let cell as DeckSelectCell://if we're going to the detail for a chosen deck
            let targetDeck: Deck = cell.deck!
            (segue.destination as! DeckDetailViewController).deck = targetDeck
            break;
        default:
            break;
        }
        
        
    }//prepareForSegue
    
    
    func updateDeckList(){
        if (currentPlayer != nil){
            if (currentPlayer!.deckList != nil){
                deckList = [Deck](currentPlayer!.deckList!)
                
                deckList!.sort()
            }//if no decks (nil value?)
            else{
                currentPlayer!.deckList = Set<Deck>()
                deckList = []
            }//else
        }//if there is a current player set
    }//updateDeckList
    
    
    /**
     Triggers when user pushes button to add a deck.
     */
    @IBAction func addDeckButtonPress(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "DeckDetailSegue", sender: sender)
        
    }//addDeckButtonPress
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (deckList != nil){
            return deckList!.count;
        }
        else{
            return 0
        }
    }//rowsInSection
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDeck: Deck = deckList![indexPath.row]
        
        let newCell: DeckSelectCell = tableView.dequeueReusableCell(withIdentifier: "DeckSelectCell") as! DeckSelectCell
        newCell.setNewDeck(cellDeck)
        
        return newCell
        
    }//cellForRowAtIndexPath
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let sourceCell = self.tableView(tableView, cellForRowAt: indexPath)
        
        performSegue(withIdentifier: "DeckDetailSegue", sender: sourceCell)
        
    }//accessoryButtonTapped
    
    
    
}//DeckSelectViewController
