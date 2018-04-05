//
//  PlayerSelectTableView.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/27/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class PlayerSelectTableViewController: UITableViewController{
    
    @IBOutlet var PlayerSelectTableView: PlayerSel!
    
    var selectedPlayer: Player? = nil
    
    override func viewDidLoad() {

        
    }//viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        
    }//viewWillAppear
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayerSelectSegue"{
            
            let nextVC: DeckSelectViewController = segue.destination as! DeckSelectViewController
            let chosenPlayer: Player = sender as! Player
            
            nextVC.currentPlayer = chosenPlayer
            
        }//if we're selecting a player
        
    }//prepare for segue
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let playerFR: NSFetchRequest<Player> = Player.fetchRequest()
        var results: [Player] = []
        do{
            results = try context.fetch(playerFR)
        }
        catch{
            NSLog("Error fetching player list from core data: \(error)")
        }
        return results.count
    }//rowsInSection
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PlayerSelectCell = tableView.dequeueReusableCell(withIdentifier: "PlayerSelectCell") as! PlayerSelectCell
        
        let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let playerFR: NSFetchRequest<Player> = Player.fetchRequest()
        var results: [Player] = []
        do{
            results = try context.fetch(playerFR)
        }
        catch{
            NSLog("Error fetching player list from core data: \(error)")
        }
        
        cell.setPlayer(player: results[indexPath.row])
        
        return cell
        
    }//cellForRowAtIndexPath
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let senderCell = self.tableView(tableView, cellForRowAt: indexPath) as! PlayerSelectCell
        
        self.performSegue(withIdentifier: "PlayerSelectSegue", sender: senderCell.player!)
    }

    
    
}//PlayerSelectTableViewController
