//
//  CardSearchViewController.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/27/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CardSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    
    @IBOutlet var cardSearchTable: UITableView!
    @IBOutlet var cardSearchBar: UISearchBar!
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var parentDeckDetailVC: DeckDetailViewController?
    
    var cardNameList: CardNameList? = nil
    var currentlyVisibleNames: [String] = []
    var namesToAddSet: Set<String> = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cnlFR: NSFetchRequest<CardNameList> = CardNameList.fetchRequest()
        var results: [CardNameList] = []
        do{
            results = try context.fetch(cnlFR)
        }
        catch{
            NSLog("Error fetching player list from core data: \(error)")
        }
        
        cardNameList = results[0]
        currentlyVisibleNames = cardNameList!.cardNames!
        
        cardSearchBar.delegate = self
        
        cardSearchBar.placeholder = "Search Cards"
        definesPresentationContext = true
        
        cardSearchTable.dataSource = self
        cardSearchTable.delegate = self
 
    }//viewDidLoad
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Regardless of how we get out, we're adding the marked cards
        view.endEditing(true)
        parentDeckDetailVC?.addCardsByNames(nameList: namesToAddSet)
        
    }//viewWillDisappear
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }//doneButtonPressed
    
    //MARK: Responding to card selection
    
    func respondToCardAddPress(name: String){
        
        if !(namesToAddSet.contains(name)){
            namesToAddSet.insert(name)
        }
        else{
            NSLog("Weird Behavior: attempting to double-add card name")
        }
        
    }//respondToCardAddPress
    
    func respondToCardRemovePress(name: String){
        
        if (namesToAddSet.contains(name)){
            namesToAddSet.remove(name)
        }
        else{
            NSLog("Weird Behavior: attempting to remove card name that isn't in the chosen set")
        }
        
    }//respondToCardRemovePress
    
    
    //MARK: Datasource and Search things
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        if cardSearchBar.text == nil{
            return true
        }
        return cardSearchBar.text!.isEmpty
    }//searchBarIsEmpty
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        var searchingText: String = CardSearchViewController.sterilizeQuotes(searchText)
        
        currentlyVisibleNames = cardNameList!.cardNames!.filter({( name : String) -> Bool in
            return name.lowercased().contains(searchingText.lowercased())
        })
        
        
        let relevantText: String = searchingText.lowercased()
        
        currentlyVisibleNames.sort { (lhs, rhs) -> Bool in
            if ((lhs.lowercased().hasPrefix(relevantText) == true) && (rhs.lowercased().hasPrefix(relevantText) == false)){
                return true
            }
            if ((lhs.lowercased().hasPrefix(relevantText) == false) && (rhs.lowercased().hasPrefix(relevantText) == true)){
                return false
            }
            
            return (lhs.lowercased() < rhs.lowercased())
  
        }//sort (prioritize first letters correct)
        
        cardSearchTable.reloadData()
    }//filterContent
    
    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchBar.text!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFiltering()){
            return currentlyVisibleNames.count
        }
        else{
            return cardNameList!.cardNames!.count
        }
    }//numberOfRowsInSection
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardSearchCell") as! CardSearchCell
        
        
        var cardName: String = ""
        if (isFiltering()){
            cardName = currentlyVisibleNames[indexPath.row]
        }//if we're filtering the search results
        else{
            cardName = cardNameList!.cardNames![indexPath.row]
        }//if the search bar is empty
        
        let cardAlreadyPicked: Bool = namesToAddSet.contains(cardName)
        
        cell.setCardName(name: cardName, delegate: self, isPressed: cardAlreadyPicked, atPath: indexPath)
        
        return cell
    
    }//cellForRowAtIndexPath
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }

    static func sterilizeQuotes(_ oldString: String) -> String{
        return oldString.replacingOccurrences(of: "’", with: "\'")
    }//sterilizeQuotes
}//CardSearchViewController
