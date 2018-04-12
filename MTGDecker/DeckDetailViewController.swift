//
//  DeckDetailViewController.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/27/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MTGSDKSwift

class DeckDetailViewController: UITableViewController, UIPopoverPresentationControllerDelegate{
    
    @IBOutlet var cardTable: CardTableView!
    @IBOutlet weak var deckTitleBar: UINavigationItem!
    @IBOutlet weak var deckNameEditButton: UIBarButtonItem!
    @IBOutlet weak var statisticsButton: UIBarButtonItem!
    @IBOutlet weak var addCardButton: UIBarButtonItem!
    @IBOutlet weak var simulatorButton: UIBarButtonItem!
    
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var deck: Deck?
    var builder: DeckBuilder?
    
    override func viewDidLoad() {
        
        //Important: must set the deck for the DeckDetailViewController as part of preparing for the segue into it
        self.builder = DeckBuilder(inContext: context, deck: deck!)
        
        cardTable.delegate = self;
        NotificationCenter.default.addObserver(forName: .cardAddNotification, object: nil, queue: nil) { (notification) in
            self.cardWasAdded()
        }
        NotificationCenter.default.addObserver(forName: .cardCellRemoveNotification, object: nil, queue: nil) { (notification) in
            self.removeCardCell(notification.object as! CardTableCell)
        }
        
    }//viewDidLoad
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CardSearchSegue"{
            (segue.destination as! CardSearchViewController).parentDeckDetailVC = self
        }//if Card Search destination
        
    }//prepare for segue
    
    @IBAction func addCardButtonPress(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "CardSearchSegue", sender: sender)
    }//addCardButtonPress
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        deckTitleBar.title = self.deck!.name!
        
        
        self.navigationController?.setToolbarHidden(false, animated: true)
    }//viewWillAppear
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func presentCardImage(forCard: MCard){
        if (forCard.image == nil){
            
            print("No image yet for card \(forCard.name)")
            
            let imageURL = forCard.imageURL!
            
            NotificationCenter.default.addObserver(forName: .cardImageAddNotification , object: forCard, queue: nil) { (notification) in
                self.presentCardImage(forCard: forCard)
            }
            
            DispatchQueue.global().async {
                self.builder!.pullCardImageByNameAndURL(name: forCard.name, url: imageURL, intoMCard: forCard)
            }

        }//if the card has no image
        
        let cardImage: UIImage = forCard.image!.image
        
        let newVC: CardImageViewController = storyboard!.instantiateViewController(withIdentifier: "CardImageViewController") as! CardImageViewController
        newVC.modalPresentationStyle = .popover
        
        newVC.loadView()
        newVC.imageView.image = cardImage
        
        present(newVC, animated: true, completion: nil)

        
        let popoverPresentationController = newVC.popoverPresentationController
        popoverPresentationController!.delegate = self
        popoverPresentationController!.sourceView = self.cardTable
        popoverPresentationController!.backgroundColor = UIColor.clear
        
        
    }//presentCardImage
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    //MARK: Deck Editing
    
    /**
     Triggers when user hits the "Edit" button to change the deck name
     */
    @IBAction func deckEditButtonPress(_ sender: UIBarButtonItem) {
        let editAlertController: UIAlertController = UIAlertController(title: deck!.name!, message: "Edit Deck Name?", preferredStyle: .alert)
        
        let confirmEditAction: UIAlertAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            self.deck!.name = editAlertController.textFields?[0].text
            self.deckTitleBar.title = self.deck!.name
            do{
                try self.context.save()
            } catch{
                NSLog("Error changing deck title in core data: \(error)")
            }
        }//confirm deck title edit
        let cancelEditAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            //Cancel the edit (do nothing)
        }//cancel deck title edit
        editAlertController.addTextField { (textfield) in
            textfield.placeholder = "Deck Name"
        }//textfield
        
        editAlertController.addAction(confirmEditAction)
        editAlertController.addAction(cancelEditAction)
        
        self.present(editAlertController, animated: true, completion: nil)
        
    }//deckEditButtonPress

    /**
     Adds cards to the deck object by way of card names. Does so by first checking the Core Data database for the card (in case it were added in another deck, or added and then removed). If the card isn't there, pulls its info from the internet.
     Called by the CardSearchVC. Immediately throws the job to the DeckBuilder object; however, method pulled in here to better encapsulate the flow of information.
   
     - parameter nameList: A set of strings indicating the names of cards we wish to add to the deck
     
     */
    func addCardsByNames(nameList: Set<String>){
        self.builder!.addCardsByNames(cardNames: nameList)
    }//addCardsByNames
    
    /**
        Called from a notification when a card is added. Currently, just reloads the table data
     */
    func cardWasAdded(){
        DispatchQueue.main.async {//big ol' thread shenanigans to make the compiler happy
            self.cardTable.reloadData()
        }
    }//cardWasAdded
    

    
    func removeCardCell(_ cell: CardTableCell){
        //confirm we want to remove it
        let removeCellAlertController: UIAlertController = UIAlertController(title: "Remove Card", message: "Are you sure you want to remove \(cell.card!.name) from your deck?", preferredStyle: .alert)
        
        let confirmRemoveAction: UIAlertAction = UIAlertAction(title: "Remove", style: .destructive) { (_) in
            
            _ = self.deck!.removeCard(cell.card!, context: self.context)

            
            do{
                try self.context.save()
            } catch{
                NSLog("Error removing card from core data: \(error)")
            }
            
            self.cardTable.reloadData()
            
        }//confirm card cell removal
        let cancelRemoveAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            cell.quantityStepper.value = 1 //brings the card count back to one, just in case
        }//cancel card removal
        
        removeCellAlertController.addAction(confirmRemoveAction)
        removeCellAlertController.addAction(cancelRemoveAction)
        
        self.present(removeCellAlertController, animated: true, completion: nil)

    }//removeCardCell
    
    //MARK: Table Functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let sortedDeck: [[(MCard, Int)]] = deck!.getCardsSorted()
        var unused: [Int] = []
        for i in 0..<7{
            if sortedDeck[i].isEmpty{unused.append(i)}
        }//for each type
        
        if unused.count == 7{
            return 1
        }
        
        return 7 - unused.count
    }//numberOfSections
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sortedDeck: [[(MCard, Int)]] = deck!.getCardsSorted()
        var unused: [Int] = []
        for i in 0..<7{
            if sortedDeck[i].isEmpty{unused.append(i)}
        }//for each type
        
        if (unused.count == 7){
            return "Press below to add a card"
        }//if no cards yet
        
        
        var titleArray: [String] = []
        for i in 0..<7{
            if unused.contains(i) == false{
                titleArray.append(MCard.typeSortArray[i])
            }//if we're using a type, put it's title in the list of used titles
        }//for
        
        return titleArray[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if deck!.getCardTotal() == 0{
            return 0
        }
        
        let sortedDeck = deck!.getCardsSorted()
        
        var usedSections: [Int] = []
        for i in 0..<7{
            if !sortedDeck[i].isEmpty{usedSections.append(i)}
        }//for each type
        
        return sortedDeck[usedSections[section]].count

    }//numberOfRowsInSection
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sortedDeck: [[(MCard, Int)]] = deck!.getCardsSorted()
        var usedSections: [Int] = []
        for i in 0..<7{
            if !sortedDeck[i].isEmpty{usedSections.append(i)}
        }//for each type
        
        
        let resultCard = sortedDeck[usedSections[indexPath.section]][indexPath.row].0
        let resultQuantity = sortedDeck[usedSections[indexPath.section]][indexPath.row].1
        
        let resultCell = tableView.dequeueReusableCell(withIdentifier: "CardTableCell") as! CardTableCell
        
        resultCell.setCellCard(resultCard)
        resultCell.setDeck(self.deck!)
        resultCell.setCellQuantity(resultQuantity)
        resultCell.setPath(indexPath)
        
        return resultCell
        
    }//cellForRowAtIndexPath
    
    /**
     Called when accessory button tapped for a Card cell. Gets the DeckDetailVC to create an image popover
     */
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let sortedDeck: [[(MCard, Int)]] = deck!.getCardsSorted()
        var usedSections: [Int] = []
        for i in 0..<7{
            if !sortedDeck[i].isEmpty{usedSections.append(i)}
        }//for each type
        
        
        let resultCard = sortedDeck[usedSections[indexPath.section]][indexPath.row].0
        
        self.presentCardImage(forCard: resultCard)
    }//accessory button tapped
    
}//DeckDetailViewController


